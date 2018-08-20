# run: awk -f getBoxCoorrdinate_10012.awk ~/Projection/mtp-data/RealDataset/10012/data/box/BGal_000000.box
BEGIN {FS=" ";i=0;l=0;print("x,y")}
{ 		
	i++;
	if (NF > 3 )
	{
			hw=$3/2;
			hh=$4/2; 
			printf("%d,%d\n",$1+hw,$2+hh);
			l++;							
	}
}
END {
 
}

