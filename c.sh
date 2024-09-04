# the merging took a lot of time so I want to make a bigger instance
# with 72 cores to speed up the merge process using multiple cores


# so using ukb-rap rate card I make a machine with 72 cores

pyenv activate dx
dx login
# go through login process and enter the username (mahdimir) and password

dx run --instance-type mem1_ssd1_v2_x72 app-cloud_workstation


# after the creation is done I take the job id and ssh to the machine
dx ssh job-GqFpFJjJzVpzz1f06YBB7PfF

# I should download the file and extract it

# I should first select the project then I can download the file
# to do this I should select the project and set the project id

dx select --level VIEW
# I select the 0.wgs from the menu

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

# dx download sorted_vcfs.tar.gz
dx download file-GqFkpy8JzVpb8qQJp1KJ9Jvy

mkdir sorted_vcfs
tar -xzvf sorted_vcfs.tar.gz -C sorted_vcfs/


# now I create the list of files to merge
d1="/home/dnanexus/sorted_vcfs/"
ls $d1*.vcf.gz > vcf_list.txt

# first install bcftools
sudo apt-get install bcftools

# now I should merge the files using bcftools
# bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt

# I want to use multiple cores to speed up the process
bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt --threads 72

# i got this error:
# Error: Duplicate sample names (1028404), use --force-samples to proceed anyway.
# maybe I should use the force-samples option but I suspect that 
# maybe every id in all vcf files is the same, I should check this

# I should first check the header of a single vcf file different from the one I checked before

f2="/home/dnanexus/sorted_vcfs/sorted_1092919_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf"
grep "^#CHROM" $f2
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  2932080
# it is not the same, can I count the number of duplicate ids in all vcf files?



d1=/home/dnanexus/sorted_vcfs/
touch samples.txt
for file in $d1*.vcf; do
    bcftools query -l $file >> samples.txt
done

# I counted the number of duplicates in the samples.txt file and I got only 1
# so I should use the --force-samples option

# I want to use multiple cores to speed up the process
bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt --threads 72 --force-samples




