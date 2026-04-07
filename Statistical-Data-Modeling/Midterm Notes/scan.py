
import os
import re

MATCH_CHUNK = re.compile(r"^```(r|\{R[^}]*\})\s*([^`]*)\s*^```", re.M | re.S | re.I)
MATCH_LIBRARY = re.compile(r"^library\([^)]+\)")
MATCH_CALL = re.compile(r"([a-zA-Z0-9._]+)\(")

FILES = [
  # "../Assignments/1/Assignment-1.Rmd",
  "../Assignments/1/Assignment-1-Response.Rmd",
  # "../Assignments/2/Assignment-2.Rmd",
  "../Assignments/2/Assignment-2-Response.Rmd",
  # "../Assignments/3/Assignment-3.Rmd",
  "../Assignments/3/Assignment-3-Response.Rmd",
  "../Assignments/3/F-Statistic Notes.Rmd",
  # "../Assignments/4/Assignment-4.Rmd",
  "../Assignments/4/Assignment-4-Response.Rmd",
  # "../Assignments/5/Assignment-5.Rmd",
  "../Assignments/5/Assignment-5-Response.Rmd",
  # "../Assignments/6/Assignment-6.Rmd",
  "../Assignments/5/Outliers-Influencers.Rmd",
  "../Assignments/6/Assignment-6-Response.Rmd",
  # "../Assignments/7/Assignment-7.Rmd",
  "../Assignments/7/Assignment-7-Response.Rmd",
  # "../Assignments/8/CSCI E-106 Assignment 8 Response.Rmd",
  # "../Labs/3/Lab03Spring20261.Rmd",
  # "../Lectures/1/Lecture 1 R Codes Part 1.Rmd",
  # "../Lectures/3/Deck 3 Codes.Rmd",
  # "../Lectures/4/MLR Part II.Rmd",
  # "../Lectures/4/MLR Part I.Rmd",
  # "../Lectures/9/Remedial Measures Rcodes/Ridge Lasso and ElasticNet -BodyFat.Rmd",
  "../Modules/Week 1/CSCI E-106 Assignment 1Solutions.Rmd",
  "../Modules/Week 1/Lecture 1 R Codes Part 1.Rmd",
  "../Modules/Week 2/CSCI E-106 Assignment 2 - Solutions.Rmd",
  "../Modules/Week 3/Deck 3 Codes.Rmd",
  "../Modules/Week 3/Lab02Spring2026.Rmd",
  "../Modules/Week 4/CSCI E-106 Assignment 4_Solutions_.Rmd",
  "../Modules/Week 4/MLR Part II.Rmd",
  "../Modules/Week 4/Lab03Spring20261.Rmd",
  "../Modules/Week 4/MLR Part I.Rmd",
  "../Modules/Week 5/CSCI_E_106_Assignment_5_solutions.Rmd",
  "../Modules/Week 5/Cross Validation.Rmd",
  "../Modules/Week 5/Polynomial Regression.Rmd",
  # "../Modules/Week 5/Lab05Spring2026.Rmd",
  "../Modules/Week 6/CSCI_E_106Assignment_6_Solutions.Rmd",
  "../Modules/Week 6/CSCI E-106 Fall 2025 Midterm Exam Solutions.Rmd",
  "../Modules/Week 6/CSCI E-106 Fall 2025 Midterm Exam.Rmd",
  "../Modules/Week 6/R Codes Model Section and Cross Validation/Variable Selection.Rmd",
  "../Modules/Week 6/R Codes Model Section and Cross Validation/Cross Validation.Rmd",
  "../Modules/Week 7/CSCI E-106 Assignment 7_solutions.Rmd",
  "../Modules/Week 7/Model_Data_Lab_Example_Bad_Data.Rmd",
  "../Modules/Week 7/Remedial Measures Rcodes/Ridge Lasso and ElasticNet -BodyFat.Rmd",
#  "../Modules/Week 7-9/Regression Tree V2.Rmd",
  "../Modules/Week 7-9/Decision Tree - Part 2.Rmd",
  "../Modules/Week 9-10/Logistic-Regression.Rmd",
  "../Modules/Week 9-10/Poisson-and-Negative-Binomial-Regression.Rmd",
]

SUBSTITUTIONS = [
      (r'/cloud/project/Data/', '/'),
      (r'//toluca_data', '/toluca_data'),
      (r'../Lectures/3/toluca_data.csv', '../Lectures/1/toluca_data.csv'),
      (r'"/Dataset_1_20.csv', '"../Lectures/3/Dataset_1_20.csv'),
      (r'../Modules/Week 3//PlasmaLevel.csv', '../Modules/Week 3/'),
      (r'all_possible_cdi_models', '# all_possible_cdi_models'),
      (r'"../Modules/Week 3/toluca_data.csv"', r'"../Lectures/1/toluca_data.csv"'),
      (r'"../Modules/Week 4/Sales Growth Data.csv"', r'"../Assignments/4/Sales Growth Data.csv"'),
      (r'"../Modules/Week 5/Commercial Properties Data Set.csv"', r'"../Assignments/5/Commercial Properties Data Set.csv"'),
      (r'PlasmaLevel <- .*', 'PlasmaLevel <- data.frame(X=c(1:20), Y=c(1:20), LogY=log(c(1:20)), lamda=c(1:20))'),
      (r'dispRegFunc', r'summary'),
      (r'((segments|points)\(simple\.loess)', r'# \1'),
      (r'(# Fit linear regression function)', r'\1\nattach(ozone)'),
      (r'best.lam=bc\$x\[which\(bc\$y==max\(bc\$y\)\)\]', r'best.lam=bc$lambda[which(bc$lambda==max(bc$lambda))]'),
      (r'teengamb.data', r'teengamb'),
      (r'../Modules/Week ./CDI Data.csv', '../Assignments/6/CDI Data.csv'),
      (r'../Assignments/./CDI Data.csv', '../Assignments/6/CDI Data.csv'),
      (r'Bonferroni_Critical_Value<-', 'p=3\nBonferroni_Critical_Value<-'),
      (r'qqPlot\(model, main = "QQ Plot"\)', r'car::qqPlot(model, main = "QQ Plot")'),
      (r'qqPlot\(f1, main = "QQ Plot"\)', r'car::qqPlot(f1, main = "QQ Plot")'),
      (r'"CH01PR19.txt"', r'"../Modules/Week 4/CH01PR19.txt"'),
      (r'"CH01PR28.txt"', r'"../Modules/Week 4/CH01PR28.txt"'),
      (r'"CH01PR20.txt"', r'"../Modules/Week 3/CH01PR20.txt"'),
      (r'"../Modules/Week 6/Machine Speed.csv"', r'"../Assignments/6/Machine Speed.csv"'),
      (r'^install.packages', r'# install.packages')
]

LIBRARIES = [
  "rlang",
  "ggplot2",
  "faraway",
  "knitr",
  "MASS",
  "formatR",
  "glue",
  "olsrr",
  "dplyr",
  "ALSM",
  "reshape",
  "pander",
  "rmarkdown",
  "markdown",
  "tidyr",
  "GGally",
  "ggpubr",
  "lmtest",
  "caret",
  "fastDummies",
  "magick",
  "tinytex",
  "ggeffects",
  "ggpubr"
]

EXTRA_LIBRARIES = [f"library({f})" for f in LIBRARIES]

if __name__ == "__main__":
  file_chunks = {}
  for file in FILES:
    file_chunks[file] = {}
    with open(file) as f:
      contents = f.read()
    for (i, chunk_match) in enumerate(MATCH_CHUNK.finditer(contents)):
      file_chunks[file][i] = chunk_match.group(2)
      # print("")
      # print(chunk_match.group(2))
      # print("")

### Generate the study guide.
  # with open("StudyGuide.Rmd", mode='w') as sg:

  #   libraries = EXTRA_LIBRARIES[:]
  #   for (file, chunks) in file_chunks.items():
  #     for (i, chunk) in chunks.items():
  #       for library_match in MATCH_LIBRARY.finditer(chunk):
  #         s = library_match.group(0)
  #         if s not in libraries:
  #           libraries.append(s)

  #   def print(l):
  #     sg.write(l + "\n")

  #   print("```{R include=FALSE}")
  #   for library in libraries:
  #     print(library)
  #   print("```")

  #   for (file, chunks) in file_chunks.items():
  #     dirname = os.path.dirname(file)
  #     print(f"### {file}\n")

  #     for (i, chunk) in chunks.items():
  #       if "## Helper to display regression function with n coefficients" in chunk:  # Junk.
  #         continue
  #       chunk = re.sub(r'read\.csv\("([^"]+)"\)', f'read.csv("{dirname}/\\1")', chunk)
  #       for (pat, repl) in SUBSTITUTIONS:
  #         chunk = re.sub(pat, repl, chunk) 
  #       print(f"```{{R}}\n{chunk}```\n\n")

  fns = {}
  fn_counts = {}
  for (file, chunks) in file_chunks.items():
    for (i, chunk) in chunks.items():
      for call_match in MATCH_CALL.finditer(chunk):
        fn = call_match.group(1)
        if i not in fns.setdefault(fn, {}).setdefault(file, []):
          fns[fn][file].append(i)
        fn_counts.setdefault(fn, 0)
        fn_counts[fn] += 1

  import json

  for (fn, _) in sorted(fn_counts.items(), key=lambda i: i[1]):
    print(json.dumps({fn: list(fns[fn].keys())}, indent=2))



  # print(json.dumps(dict(sorted(fn_counts.items(), key=lambda i: i[1])), indent=2))

# MATCH_CALL


  # for (directory, _, files) in os.walk("../"):
  #   for file in files:
  #     if not file.endswith("md"):
  #       continue
  #     print(f'  "{directory}/{file}",')
      # print(f"Processing {file}")
      # with open(f"{directory}/{file}") as f:
      #   contents = f.read()
      # for chunk_match in MATCH_CHUNK.finditer(contents):
      #   print("")
      #   print(chunk_match.group(0))
      #   print("")
