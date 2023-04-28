import sys
import subprocess

subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])

import pandas as pd

df = pd.read_csv("/mnt/data/examples/example.csv", sep=";")

print(df.to_string())
