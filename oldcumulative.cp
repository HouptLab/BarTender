void Experiment::CreateCumulativeFile(char *name) {	FILE *fp;	short r,i;	ItemType *item;	char ratname[32],prefname[50];	short numRats,numItems;	RatType *rat;	GroupType *group;		fp = fopen(name,"w");		numRats = GetNumRats();	numItems = GetNumItems();	// write the rat IDs as the first header line		fprintf(fp,"\t\t\t"); // space for time on & time off			if (HasPreference()) {					for (r=0;r < numRats; r++) {			TagRat2Text(tag,r,ratname);			fprintf(fp,"%s \t", ratname);		}			fprintf(fp,"\t\t\t");			}			for (i=0;i<numItems;i++) {		item = GetAnItem(i);		for (r=0;r < numRats; r++) {				TagRat2Text(tag,r,ratname);				fprintf(fp,"%s\t",ratname);		}		fprintf(fp,"\t\t\t");	}	fprintf(fp,"\n");	// write the group assignments as the second header line		fprintf(fp,"\t\t\t"); // space for time on & time off			if (HasPreference()) {					for (r=0;r < numRats; r++) {			rat = (RatType *)rats->GetMember(r);			group = (GroupType *)groups->GetMember(rat->group);			fprintf(fp,"%s \t", group->tag);		}			fprintf(fp,"\t\t\t");			}			for (i=0;i<numItems;i++) {		item = GetAnItem(i);		for (r=0;r < numRats; r++) {				rat = (RatType *)rats->GetMember(r);				group = (GroupType *)groups->GetMember(rat->group);				fprintf(fp,"%s \t", group->tag);		}		fprintf(fp,"\t\t\t");	}	fprintf(fp,"\n");	// write the data field names as the third header line			fprintf(fp,"Time ON\tTime OFF\t\t");			if (HasPreference()) {			GetPreferenceText(prefname);		for (r=0;r < numRats; r++) {						fprintf(fp,"%s Pref\t", prefname);		}			fprintf(fp,"\t\t\t");			}			for (i=0;i<numItems;i++) {		item = GetAnItem(i);		for (r=0;r < numRats; r++) {				fprintf(fp,"%s\t",item->name);		}		fprintf(fp,"\t\t\t");	}	fprintf(fp,"\n");	fclose(fp);	}void DailyData::SaveCumulative(Experiment *expt,FILE *fp) {		short r,i;	char ondatetime[100],offdatetime[100],preftext[50];;	ItemType *item;	double onwgt,offwgt,deltawgt;	if (onWeight == NULL || offWeight == NULL)  return;		Secs2TimeStr(onTime,ondatetime,SHORTDATE,HRCOLON);	Secs2TimeStr(offTime,offdatetime,SHORTDATE,HRCOLON);	fprintf(fp,"%s\t%s\t\t",ondatetime,offdatetime);					if (expt->HasPreference()) {			for (r=0;r < numRats; r++) {			expt->GetPrefScoreText(r,preftext);			fprintf(fp,"%s\t", preftext);		}			fprintf(fp,"\t\t\t");			}	for (i=0;i<numItems;i++) {		for (r=0;r < numRats; r++) {							GetWeights(r,i,&onwgt,&offwgt,&deltawgt);				if (deltawgt != MISSINGWGT) {					fprintf(fp,"%.2f\t",deltawgt);				}				else {					fprintf(fp,"--\t");								}						}		fprintf(fp,"\t\t\t");			}	fprintf(fp,"\n");}