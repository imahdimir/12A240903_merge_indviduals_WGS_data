# so working with bed files outputted by plink2 didn't work 
# so I want to try to merge the original vcf files outputted by tabix using bcftools

# I have all the output files by tabix on the UKB-RAP in this path
# WGS:project-Gjz9YXjJzVpj2P4v2vFpg4GP:/projects_data/12A240903_merge_indviduals_WGS_data/inp/filtered.tar.gz (file-Gp9f0x8JzVpx4xKyQ446qFgB)

# I will create a machine on the UKB-RAP and download the file and extract it
# making a two core machine on ukb-rap, now I choose a small machine to test
# then If having more cores would fasten the process I will make a bigger machine
dx run --instance-type mem1_ssd1_v2_x2 app-cloud_workstation

# after the creation is done I take the job id and ssh to the machine
dx ssh #job-GqFfXY0JzVpyYx0q89KBFFGk

# I should download the file and extract it

# I should first select the project then I can download the file
# to do this I should select the project and set the project id

dx select --level VIEW
# I select the 0.wgs from the menu

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

# now dx ls works for the project, to test I am connected to project 
# files I should run dx ls once to see what happens if it works then 
# everything is fine, dx ls

# one cool feature is that files has ids on the UKB-RAP so I can use the id instead of the path
# I can use the id to download the file
dx download file-Gp9f0x8JzVpx4xKyQ446qFgB

# then I extract the file
tar -xvf filtered.tar.gz

# now I have the files in the path ~/filtered

# now I should find out how to merge these using bcftools

# I should first install bcftools
sudo apt-get install bcftools


# I want to know whether individual id is included in the vcf files or they
# are only included in the filenames?
# to do this Im going to check the header of a single vcf file

f1="/home/dnanexus/filtered/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf"
grep "^#CHROM" $f1

# I got this output:
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  1028404

# so it seems that the individual id is included in the vcf files but
# if the last column is the individual id then it is 
# different from the file name, I should look it up in the 
# imputed data to see whether this individual id is present in the list of individuals

# dx-get-timeout
# dx-set-timeout 3h


# apparentaly vcf files should be sorted before merging them,
# I suppose that Tabix outputted the files in a sorted manner, any other
# assumption doesn't make sense, so I don't sort them unless later I found that
# they are not sorted

# I changed my mind I check one of the files with bcf tools with the following command
# to check whether the files are sorted or not

# bcftools index --csi file.vcf
# if this command runs without error then the file is sorted 
# otherwise it is not sorted and I should sort vcf files before merging them

f1="/home/dnanexus/filtered/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf"
bcftools index --csi $f1

# I got this error:
# index: the file is not BGZF compressed, cannot index: /home/dnanexus/filtered/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf
# I should first bgzip the files then index them

# to bgzip the files I should use the following command
bgzip -c /home/dnanexus/filtered/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf > /home/dnanexus/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf.gz
# but this command doesn't work because tabix is not installed on the machine
# I should install tabix first
sudo apt install tabix

# then I can use the following command to bgzip the files
bgzip -c /home/dnanexus/filtered/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf > /home/dnanexus/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf.gz

# now I have the bgzipped file I should check if it is sorted or not (hopefully it is sorted and tabix doesn't sort it meanwhile compressing it)
bcftools index --csi /home/dnanexus/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf.gz


# so I get this error:
# cftools index --csi /home/dnanexus/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf.gz
# [E::hts_idx_push] Unsorted positions on sequence #6: 10696283 followed by 10696272
# index: failed to create index for "/home/dnanexus/1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf.gz"

# this means that vcf files are not sorted so first I should sort them

# now I want to sort files in the filtered directory
#     bcftools sort -o sorted_"$file" $d1"$file"

cd /home/dnanexus/filtered
d1="/home/dnanexus/sorted_vcfs/"

# first I test the command on a single file

f1="1070340_24053_0_0.dragen.hard-filtered.vcf.filtered.vcf"
bcftools sort -o $d1"sorted_"$f1 $f1

for file in *.vcf; do
    bcftools sort -o $d1"sorted_"$file $file
done

# then I'll check all the files are sorted or not using bcftools index --csi command

# first I should bgzip the files
cd $d1
for file in *.vcf; do
    bgzip -c $file > $file.gz
done

# Then I should index the files using bcftools index --csi command to check whether they are sorted or not before merging them
cd $d1
for file in *.gz; do
    bcftools index --csi $file
done

# so it was successful and all the files are sorted so finally I can merge them hopefully

# before merging I should save sorted files in the WGS project for future use
# I save it in the med folder in the current 12A240903_merge_indviduals_WGS_data project

dx cd projects_data/12A240903_merge_indviduals_WGS_data
dx mkdir med
dx cd med

# first I compress the sorted_files directory before uploading it to the UKB-RAP
tar -cvzf sorted_vcfs.tar.gz /home/dnanexus/sorted_vcfs
dx upload sorted_vcfs.tar.gz

# now I create the list of files to merge
ls $d1*.vcf.gz > vcf_list.txt

# now I should merge the files using bcftools
bcftools merge -O z -o merged_output.vcf.gz -l vcf_list.txt
