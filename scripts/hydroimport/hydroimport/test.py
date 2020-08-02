import argparse
import os

parser = argparse.ArgumentParser(description='testing args')
parser.add_argument('integers', metavar='N', type=int, nargs='+')
parser.add_argument('--sum', dest='accumulate', action='store_const', const=sum, default=max)
parser.add_argument('-p', '--path')
parser.add_argument('-c', '--chicken')
parser.add_argument('-l', '--left')

args = parser.parse_args()
print(args)
print(args.integers)
print(args.accumulate(args.integers))

print(os.path.isdir(args.path.strip('"')))