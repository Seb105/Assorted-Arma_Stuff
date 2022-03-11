from re import S
import numpy as np
import matplotlib.pyplot as plt

import librosa
import librosa.display
import pydub

CHUNK_LENGTH_MS = 5000
OVERLAP_MS = 300
OUTPUT_RATE = 15
SAMPLE_RATE = 22050
N_FFT = 1024
HOP_LENGTH = 512
NO_VOLUME = -80
AUDIO_PATH = "song.ogg"


def main():
    all = process_song(AUDIO_PATH)
    fig, ax = plt.subplots()
    x = np.arange(0, len(all[0])) * (1 / OUTPUT_RATE)
    for i, output in enumerate(all):
        line = ax.plot(x, output)[0]
        line.set_label(("Bass", "Mid", "Treble")[i])
    ax.set_ylabel("Amplitude")
    ax.set_xlabel("Time (s)")
    ax.legend(loc='lower left')
    fig.show()
    input()


def output_sqf_array(array):
    string = str(array)
    indent = 0
    indent_str = "    "
    output = ""
    for char in string:
        if char == "[":
            indent += 1
            output += char + "\n" + indent_str * indent
        elif char == "]":
            indent -= 1
            output += "\n" + indent_str * indent + char
        elif char == ",":
            output += char + "\n" + indent_str * indent
        elif char == " ":
            pass
        else:
            output += char
    return output


def process_song(main_path):
    print("Processing audio")
    audio = pydub.AudioSegment.from_ogg(main_path)
    chunks = []
    for i in range(0, len(audio), CHUNK_LENGTH_MS):
        slice_end = min(i + CHUNK_LENGTH_MS, len(audio)-1)
        chunks.append(audio[i:slice_end])
    volume_array = []
    paths = []
    for i, chunk in enumerate(chunks):
        path = f"song/seb_song_{i}.ogg"
        print(f"Processing {path}")
        chunk.export(path, format="ogg")
        volume_array.append(process_spectrum(path))
        paths.append(path)
    write_description(paths)
    with open("scriptBase.sqf", "r") as r:
        script_base = r.readlines()
        for i, line in enumerate(script_base):
            script_base[i] = line.replace('["REPLACE ME"]', output_sqf_array(volume_array))
        with open("script.sqf", "w") as f:
            f.writelines(script_base)
    all_bass = []
    all_mid = []
    all_treble = []
    for chunk in volume_array:
        all_bass.extend(chunk[0])
        all_mid.extend(chunk[1])
        all_treble.extend(chunk[2])
    return [all_bass, all_mid, all_treble]

def write_description(paths):
    with open("description.ext", "w") as f:
        f.write("class CfgSounds {\n")
        f.write("    sounds[] = {};\n")
        for file in paths:
            classname = file.split(".")[0].split("/")[-1]
            f.write(f"    class {classname} {{\n")
            f.write(f"        name = \"{classname}\";\n")
            f.write(f"        sound[] = {{\"\\song\\{classname}.ogg\", db+25, 1, 500}};\n")
            f.write(f"        titles[] = {{0, \"\"}};\n")
            f.write(f"    }};\n")
        f.write("};")


def process_spectrum(path):
    S_db, sr = get_spectrum(path)
    frequencies = []
    for lower, upper in (60, 250), (4000, 6000), (7000, 9000):
        extracted_range = extract_frequency_range(S_db, sr, lower, upper)
        # show_graph(extracted_range, sr)
        resampled_range = avg_and_resample_range(
            extracted_range, OUTPUT_RATE)
        standardised_range = standardise_frequency_range(resampled_range)
        frequencies.append(list(standardised_range))
    return frequencies


def extract_percussion(y, sr):
    y_harm, y_perc = librosa.effects.hpss(y)
    fig, ax = plt.subplots(nrows=3, sharex=True)
    librosa.display.waveshow(y_harm, sr=sr, alpha=0.5,
                             ax=ax[2], label='Harmonic')
    librosa.display.waveshow(y_perc, sr=sr, color='r',
                             alpha=0.5, ax=ax[2], label='Percussive')
    ax[2].set(title='Multiple waveforms')
    ax[2].legend()
    fig.show()
    print("Shown figure")


def show_graph(S, sr):
    print("Showing figure")
    fig, ax = plt.subplots()
    img = librosa.display.specshow(
        S, y_axis='log', x_axis='time', ax=ax, sr=sr)
    ax.set_title('Power spectrogram')
    fig.colorbar(img, ax=ax, format="%+2.0f dB")
    fig.show()
    print("Shown figure")


def get_spectrum(path):
    y, sr = librosa.load(path, sr=SAMPLE_RATE, mono=True)
    S_a = np.abs(librosa.stft(y, n_fft=N_FFT, hop_length=HOP_LENGTH))
    S_db = S_a  # librosa.amplitude_to_db(S_a, ref=np.max)
    return S_db, sr


def extract_frequency_range(S, sr, lower, upper):
    S = np.copy(S)
    frequencies = librosa.fft_frequencies(sr, n_fft=N_FFT)
    lower_index = np.size((np.where(frequencies <= lower)))
    upper_index = np.size((np.where(frequencies < upper)))
    if lower_index != 0:
        S[:lower_index].fill(NO_VOLUME)
    if upper_index != 0:
        S[upper_index:].fill(NO_VOLUME)
    return S


def avg_and_resample_range(S, to_freq):
    summed = np.amax(S, axis=0)  # sum over columns
    all = np.empty(0)
    last = float(np.size(summed)-1)
    prev = 0.0
    time_per_hop = HOP_LENGTH / SAMPLE_RATE
    step = (1 / to_freq) / time_per_hop
    while prev < last:
        next = min(prev + step, last)
        slice_start = int(prev)
        slice_end = int(next)
        all = np.append(all, np.average(summed[slice_start:slice_end]))
        prev = next
    # remove last element as for some reason it ruins everything
    return all[:-1]


def standardise_frequency_range(S):
    min = np.amin(S)
    max = np.amax(S)
    range = max - min
    reduced = S - min
    # normalize to 0..1
    if range != 0:
        standardised = reduced / range
        # Quadratic curve
        # quadritised = np.power(standardised, 2)
        return standardised 
    else:
        S.fill(0.5)
        return S


if __name__ == '__main__':
    main()
