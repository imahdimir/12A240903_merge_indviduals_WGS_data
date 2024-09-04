!#/bin/bash

p1="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out"
p2="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/med"

# this removes all suffixes which I don't want it
# ls $p1/*.bed | awk -F. '{print $1}' | sort | uniq > $p2/merge_list.txt

# this only removes the last suffix
ls $p1/*.bed | awk -F'.' '{OFS="."; $NF=""; sub(/\.$/, "", $0); print $0}' | sort | uniq > $p2/merge_list.txt


# now I have all the files in the merge_list.txt with .bed removed
# now I want to merge all these bed files using plink2, hopefully it will 
# produce a bed files that has genotypes for all the individuals 
# in the merge_list.txt and also all the SNPs and IIDs, god help us :-)

file1="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out/1000230_24053_0_0"
# because file 1 is included I should make sure that the first individul
# data hasn't been duplicated in the final data, I should remove the copy & keep 
# 1 only

#plink2 --bfile $file1 --merge-list merge_list.txt --make-bed --out merged
#the above command will throw this error: 
#Error: --merge-list is retired.  Use --pmerge-list instead.
# so I just use the pmerge option instead of merge-list
cd $p2
plink2 --bfile $file1 --pmerge-list merge_list.txt --make-bed --out merged

# error: Error: Failed to open
# /var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out/1000230_24053_0_0.fam: No such file or directory.
# this command only used before any . in the filenames only the first part of the filename
# so I am going to rename all the .bed .fam and .bim files to keep only the 
# first part of the file name

# before renaming I just make the final file names into a file to make sure 
# the code is going to work fine then I rename those files

cd /var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp
ls plink_out/*.bed | awk -F'.' '{OFS="."; if (NF>2) {print $1"."$NF} else {print $0}}' | sort | uniq > cleaned_list.txt

# head cleaned_list.txt 
# plink_out/1000230_24053_0_0.bed
# plink_out/1000265_24053_0_0.bed
# plink_out/1000390_24053_0_0.bed

# now I am going to rename the files
# to reduce the risk I make a copy of the dir and work on the copied dir

rm cleaned_list.txt 
# write a code that copy a dir

cp -r plink_out plink_out_copy_only_basenames

cd plink_out_copy_only_basenames
for file in *.bed; do
    # Extract base name and last suffix
    new_name=$(echo "$file" | awk -F'.' '{OFS="."; if (NF>2) {print $1"."$NF} else {print $0}}')
    # Rename the file
    mv "$file" "$new_name"
done

for file in *.fam; do
    new_name=$(echo "$file" | awk -F'.' '{OFS="."; if (NF>2) {print $1"."$NF} else {print $0}}')
    mv "$file" "$new_name"
done

for file in *.bim; do
    new_name=$(echo "$file" | awk -F'.' '{OFS="."; if (NF>2) {print $1"."$NF} else {print $0}}')
    mv "$file" "$new_name"
done

for file in *.log; do
    new_name=$(echo "$file" | awk -F'.' '{OFS="."; if (NF>2) {print $1"."$NF} else {print $0}}')
    mv "$file" "$new_name"
done


# now let's try to merge the files again, I should first
# make the merge_list.txt file again with only the basenames
p3="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out_copy_only_basenames"
p4="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/med"
cd $p4
ls $p3/*.bed | awk -F. '{print $1}' | sort | uniq > $p4/merge_list.txt

# finally I merge bed files
cd $p4
file2="/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out_copy_only_basenames/1000230_24053_0_0"
plink2 --bfile $file2 --pmerge-list merge_list.txt --make-bed --out merged

# I got this error:
#Error: Failed to open
#/var/genetics/ws/mahdimir/projects_data/24Q3/12A240903_merge_indviduals_WGS_data/inp/plink_out_copy_only_basenames/1000230_24053_0_0.psam

# it seems that merging bed files doesn't work with plink2, I should try to merge
# the original vcf files outputted by tabix using bcftools and I can do that 
# only on the UKB-RAP



