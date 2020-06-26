"""
Query Search
"""
import pandas as pd, os, argparse, sys

def main(keyword,year):
    path = r"\\Mklfile\claims\corpfs06-filedrop\ClaimsReporting\Ad Hoc Reporting"
    if year == 'All':
        path = path
    else:
        yr = str(year)
        path = os.path.join(path,yr)
    dir_path = os.path.realpath(path)
    data=[]
    for root, dirs, files in os.walk(dir_path):
    #    print("root: "+root+", dirs: "+dirs+", files: "+files)
        for file in files:
            if file.endswith('.sql'):
    #            print(root+'/'+str(file))
                with open(root+'/'+file) as f:
                    for i, line in enumerate(f):
#                        line=line.replace('\n','<br>')
#                        line='<pre>'+line+'</pre>'
                        if keyword in line:
                            data.append((root+'/'+file, file, line, i+1))
                    break
    pd.set_option('display.max_colwidth', -1)
    data=pd.DataFrame(data,columns=('Path', 'File','Text','Line Number',))
    return data


if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv)
    parser.add_argument('keyword', type=str, help="Enter the keyword you want to search")
    parser.add_argument('year', type=str, help="Enter the year of the ad hoc folder")
    args = parser.parse_args()
    main(args.keyword)
    

