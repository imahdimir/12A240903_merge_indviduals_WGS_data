pyenv activate dx
dx login

dx run --instance-type mem1_ssd1_v2_x72 app-cloud_workstation

dx ssh #job-GqFpFJjJzVpzz1f06YBB7PfF

dx select --level VIEW

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

# download sorted_vcfs.tar.gz
dx download file-GqFkpy8JzVpb8qQJp1KJ9Jvy

mkdir sorted_vcfs
tar -xzvf sorted_vcfs.tar.gz -C sorted_vcf/


# now I create the list of files to merge
d1="/home/dnanexus/sorted_vcf/"
ls $d1*.vcf.gz > vcf_list.txt

# first install bcftools
sudo apt-get install bcftools

# now I should merge the files using bcftools
# bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt


# first I only merge 10 first files to see if it works
head -n 10 vcf_list.txt > vcf_list_10.txt
bcftools merge -O z -o merged_output_10.vcf.gz -l vcf_list_10.txt --threads 72
# it worked fine and outputted the merged file 
# I should first check the header of this file and 
# also converting this file to bed format using plink2 to see
# if it produces right bed file with genotypes or not?
zgrep "^#CHROM" merged_output_10.vcf.gz

bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt --threads 72 --force-samples


# now I should convert the merged vcf file to bed format using plink2
plink2 --vcf merged_output.vcf.gz --make-bed --out merged_wgs


# I got this error:
# Error: Invalid chromosome code 'chr1_KI270706v1_random' on line 95145 of --vcf
# file.
# (Use --allow-extra-chr to force it to be accepted.)

plink2 --max-alleles 2 --vcf merged_output.vcf.gz --make-bed --out merged_wgs --allow-extra-chr

# it produced the bed, fam, bim, log files but it didn't produce the .psam file



