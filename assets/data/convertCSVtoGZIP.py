import gzip, os

# get files from the directory
def getFiles(directory):
    files = []
    for file in os.listdir(directory):
        if file.endswith(".csv"):
            files.append(file)
    return files

# convert files to gzip
def convertToGZIP(directory, files):
    for file in files:
        remove_txt = file.split(".")[0]
        with open(directory + file, 'rb') as f_in, gzip.open(directory + remove_txt + '.gz', 'wb') as f_out:
            f_out.writelines(f_in)
    print("Files converted to GZIP")

# main function
def main():
    # get the path of the directory automatically
    directory = os.path.dirname(os.path.realpath(__file__)) + "/"
    files = getFiles(directory)
    convertToGZIP(directory, files)

if __name__ == "__main__":
    main()