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

# download the filtered vcf files outputted by Tabix
dx download file-Gp9f0x8JzVpx4xKyQ446qFgB

# then I extract the file
mkdir vcf
tar -xzvf filtered.tar.gz -C vcf/


# I want to make a bed file out of the vcf file with plink2 to see does it produce .psam file?
cp 1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf ~/
cd ~

# first I should install plink2
sudo apt-get install plink2

plink2 --vcf 1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf --make-bed --out test

# I got this error:
# Error: Invalid chromosome code 'chr1_KI270766v1_alt' on line 5086 of --vcf
# file.
# (Use --allow-extra-chr to force it to be accepted.)

plink2 --max-alleles 2 --vcf 1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf --make-bed --out test --allow-extra-chr

# so it doesn't produce .psam file, so I have to get back to the previous plan






