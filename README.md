
[**CLICK HERE to see rendered html report**](https://reyvaz.github.io/NLP-Corpora-Analysis/exploration_report.html)  


## Natural Language Processing: Corpus Analysis

This repository contains the R code for the preliminary analysis of three English language corpora with the purpose of building a word predictor. 

The corpora were provided by Swiftkey and were originally collected by a web crawler from publicly available news, personal blogs, and  twitter posts. More information [here](https://web-beta.archive.org/web/20160930083655/http://www.corpora.heliohost.org/aboutcorpus.html). The corpora can be downloaded [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip). 

The scripts are designed to optimize speed in small systems by breaking out corpora and regularly disposing of data when the statistic of interest has been recorded.  

* The rendered html version of the analysis can be found here  [here](https://reyvaz.github.io/NPL-Corpora-Analysis/exploration_report.html).   

* To recreate the html report:
	* Include [exploration_report.Rmd](exploration_report.Rmd)  and [reportWorkspace.Rdata](reportWorkspace.Rdata) in your directory. 
	* Source `exploration_report.Rmd`.  
	
* To recreate the report from scratch:
	* Clone this directory excluding the `reportWorkspace.Rdata` file. 
	* Download the corpora database from [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip) and extract the `en_US.blogs.txt`, `en_US.news.txt`, `en_US.twitter.txt` files and place them in a data folder in the directory. 
	* Note: [badstems.txt](badstems.txt) and [badwords.txt](badwords.txt), which filter common profanity, were purposely left empty from this public repo. A few statistics might difer slightly. Populate these or contact me for the original lists.  
	

[GitHub Pages Link](https://reyvaz.github.io/NLP-Corpora-Analysis/)  

<br>
<p align="center">
<a href="https://reyvaz.github.io/NLP-Corpora-Analysis/exploration_report.html" 
rel="see html report">
<img src="exploration_report_files/figure-html/cloud-1.png" alt="Drawing" width = "350"></a>
</p>
<br>
<hr>
<br>
