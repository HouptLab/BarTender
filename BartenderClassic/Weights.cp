// weights.cp#include "Weights.hpp"#include "ReadBalance.hpp"#include "BarOrders.hpp"#define WGT_TEXT_MARGIN 5#define WINDOW_HEIGHT 440#define WINDOW_WIDTH 620#define INPUT_FONTSIZE 18#define INPUT_HEIGHT INPUT_FONTSIZE+ WGT_TEXT_MARGIN + WGT_TEXT_MARGIN #define PROMPT_WIDTH	100#define TAG_WIDTH	100#define WEIGHT_WIDTH	100#define EXPT_WIDTH	200	Rect input_pane_box = {0,0,INPUT_HEIGHT,WINDOW_WIDTH};	Rect expt_pane_box = {INPUT_HEIGHT,0,WINDOW_HEIGHT,WINDOW_WIDTH};OnWeightsWindow *onWeightsWindow;OffWeightsWindow *offWeightsWindow;void SetMinMaxWeights(void);void InitOnWeights(void);void InitOffWeights(void);OnWeightsWindow *CreateOnWeights(char *name);OffWeightsWindow *CreateOffWeights(char *name);double min_weight = 10.0;double max_weight = 800.0;#define MINMAXDIAL 143#define OK 1#define CANCEL 2#define MINWGT 5#define MAXWGT 6void SetMinMaxWeights(void) {	short item;	DialogPtr d;	double temp;		// puts up a modal dialog which allows you to tinker		d = GetNewDialog(MINMAXDIAL,0L,(WindowPtr)-1L);		SetDDouble(d,MINWGT,min_weight);	SetDDouble(d,MAXWGT,max_weight);			FrameDefault(d);	InitCursor();		do {			ModalDialog(0L,&item);			switch (item) {								case CANCEL:				DisposeDialog(d);				return;				break;		}			} while (item != OK);		GetDDouble(d,MINWGT,&min_weight);	GetDDouble(d,MAXWGT,&max_weight);		if (min_weight > max_weight) {		temp = min_weight;		min_weight = max_weight;		max_weight = temp;	}		DisposeDialog(d);		}void InstallWeightOrders(WeightsWindow *weightsWindow); // in barorders.cpvoid InitOnWeights(void) {	onWeightsWindow = CreateOnWeights("On Weights");		}void InitOffWeights(void) {	offWeightsWindow = CreateOffWeights("Off Weights");	}OnWeightsWindow *CreateOnWeights(char *name) {	// open a window for the weights		Point maxSize;		Rect viewRect;	Point oldOrigin = {0,0};	maxSize.h = WINDOW_WIDTH; maxSize.v = WINDOW_HEIGHT;			OnWeightsWindow *weightsWindow = new OnWeightsWindow(name,maxSize);		viewRect.top = viewRect.left = 0;	viewRect.right = 1000;	viewRect.bottom = 5000;		InputViewObject *input_view = new InputViewObject();		ExptViewObject *expt_view = new ExptViewObject();			PaneObject *input_pane = new PaneObject(weightsWindow,input_view,input_pane_box,TRUE,FALSE,FALSE);	PaneObject *expt_pane = new PaneObject(weightsWindow,expt_view,expt_pane_box,TRUE,TRUE,TRUE);			weightsWindow->SetInputView(input_view);	weightsWindow->SetExptView(expt_view);	input_view->SetTag("\0");input_view->SetWeight("\0");input_view->SetExpt("\0");		InstallWeightOrders(weightsWindow);	OffWeightsCommand *off = new OffWeightsCommand(weightsWindow);	off->SetEnabled(FALSE);		return(weightsWindow);	}OffWeightsWindow *CreateOffWeights(char *name) {	// open a window for the weights		Point maxSize;		Rect viewRect;	Point oldOrigin = {0,0};	maxSize.h = WINDOW_WIDTH; maxSize.v = WINDOW_HEIGHT;				OffWeightsWindow *weightsWindow = new OffWeightsWindow(name,maxSize);		viewRect.top = viewRect.left = 0;	viewRect.right = WINDOW_WIDTH;	viewRect.bottom = WINDOW_HEIGHT;		InputViewObject *input_view = new InputViewObject();		ExptViewObject *expt_view = new ExptViewObject();			PaneObject *input_pane = new PaneObject(weightsWindow,input_view,input_pane_box,TRUE,FALSE,FALSE);	PaneObject *expt_pane = new PaneObject(weightsWindow,expt_view,expt_pane_box,TRUE,TRUE,TRUE);		weightsWindow->SetInputView(input_view);	weightsWindow->SetExptView(expt_view);		input_view->SetTag("\0");input_view->SetWeight("\0");input_view->SetExpt("\0");		InstallWeightOrders(weightsWindow);	OnWeightsCommand *on = new OnWeightsCommand(weightsWindow);	on->SetEnabled(FALSE);		return(weightsWindow);	}InputViewObject::InputViewObject() : ViewObject() {	 	 sprintf(prompt.text,"Next Item: ");	 prompt.box.left = WGT_TEXT_MARGIN;	 prompt.box.top = WGT_TEXT_MARGIN;	 prompt.box.bottom = prompt.box.top + INPUT_FONTSIZE;	 prompt.box.right = prompt.box.left + PROMPT_WIDTH;	 prompt.size = INPUT_FONTSIZE; tag.size = INPUT_FONTSIZE; weight.size = INPUT_FONTSIZE;	 	 sprintf(tag.text,"TA 001 F");	 tag.box.left = WGT_TEXT_MARGIN + prompt.box.right;	 tag.box.top = WGT_TEXT_MARGIN;	 tag.box.bottom = tag.box.top + INPUT_FONTSIZE;	 tag.box.right = tag.box.left + TAG_WIDTH;	 	 	 sprintf(weight.text,"234 g");	 weight.box.left = WGT_TEXT_MARGIN + tag.box.right;	 weight.box.top = WGT_TEXT_MARGIN;	 weight.box.bottom = weight.box.top + INPUT_FONTSIZE;	 weight.box.right = weight.box.left + WEIGHT_WIDTH;	 	 sprintf(expt.text,"Experiment");	expt.box.left = WGT_TEXT_MARGIN + weight.box.right;	 expt.box.top = WGT_TEXT_MARGIN;	 expt.box.bottom = expt.box.top + INPUT_FONTSIZE;	 expt.box.right = expt.box.left + EXPT_WIDTH; 	expt.size = INPUT_FONTSIZE;	 	}void InputViewObject::Draw(Rect *updateRect,PaneObject *pane) {		Rect b;		//SetPort(wgtWindow->GetWindowPtr());	ClipRect(updateRect);	EraseRect(updateRect);	prompt.Draw();	tag.Draw();	weight.Draw();	expt.Draw();	pane->GetBounds(&b);	MoveTo(b.left,b.bottom-1);	LineTo(b.right,b.bottom-1);		}void InputViewObject::SetTag(char *text) {	strcpy(tag.text,text); 	//SetPort(wgtWindow->GetWindowPtr());	tag.Draw();}void InputViewObject::SetExpt(char *text) {		strcpy(expt.text,text); 	//SetPort(wgtWindow->GetWindowPtr());	expt.Draw();}#define EXPT_FONTSIZE 12#define EXPT_HEIGHT (EXPT_FONTSIZE+WGT_TEXT_MARGIN)#define SUBJ_LEFT WGT_TEXT_MARGIN#define SUBJ_WIDTH 80#define ON_LEFT (SUBJ_LEFT+SUBJ_WIDTH+WGT_TEXT_MARGIN)#define SMALLWGT_WIDTH 40#define OFF_LEFT (ON_LEFT+SMALLWGT_WIDTH+WGT_TEXT_MARGIN)#define DELTA_LEFT (OFF_LEFT+SMALLWGT_WIDTH+WGT_TEXT_MARGIN)#define EXPT_COLUMN_WIDTH (3*SMALLWGT_WIDTH+4*WGT_TEXT_MARGIN)void InputViewObject::SetWeight(char *text)  {	strcpy(weight.text,text); 	SetPort(wgtWindow->GetWindowPtr());	SetOrigin(0,0);	ClipRect(&(weight.box));	weight.Draw();	}ExptViewObject::ExptViewObject() : ViewObject() {	Point m = {5000,1000};	SetMaxSize(m);	SetHiliteWeight(-1,-1);}void ExptViewObject::DrawHeadings(void) {	LabelObject item;	Experiment *expt;	short i;	unsigned long numItems;		SetRatBoxes(0);			item.size = EXPT_FONTSIZE;	item.box.top = WGT_TEXT_MARGIN;	item.box.bottom = item.box.top + EXPT_FONTSIZE;	item.justify = teJustCenter;	item.style = bold;			subject.box.top = onWeight.box.top = offWeight.box.top = deltaWeight.box.top = EXPT_HEIGHT;	subject.box.bottom = onWeight.box.bottom = offWeight.box.bottom = deltaWeight.box.bottom = subject.box.top + EXPT_FONTSIZE;		subject.style = onWeight.style = offWeight.style = deltaWeight.style = bold;	sprintf(subject.text,"Subject");	subject.Draw();		expt = wgtWindow->GetExpt();		if (expt != NULL) {			numItems = expt->GetNumItems();				for (i=0;i<numItems;i++) {					ItemType *theItem;						theItem = expt->GetAnItem(i);						SetItemBoxes(i);			item.box.left = onWeight.box.left;			item.box.right = deltaWeight.box.right;			sprintf(onWeight.text,"On");			sprintf(offWeight.text,"Off");			sprintf(deltaWeight.text,"�");						sprintf(item.text,theItem->name);			item.Draw();			onWeight.Draw();			offWeight.Draw();			deltaWeight.Draw();			}				if (expt->HasPreference()) {					SetItemBoxes(numItems);			item.box.left = onWeight.box.left;			item.box.right = deltaWeight.box.right;			expt->GetPreferenceText(item.text);			sprintf(onWeight.text,"Pref");			item.justify = teJustLeft;			item.Draw();			onWeight.Draw();					}			}				subject.style = onWeight.style = offWeight.style = deltaWeight.style = 0;}void ExptViewObject::FixOrigin(short rat) {	Point p;	Rect box;	short bottom,top;	Object *o;	PaneObject *pane;					SetRatBoxes(rat);		bottom = subject.box.bottom;	top = subject.box.top;		FORALL(o,ownerPanes) {			pane = (PaneObject *)o;				pane->GetPaneOrigin(&p);		pane->GetBounds(&box);						if 	(bottom > (box.bottom - box.top) + p.v) {						p.v = bottom - (box.bottom - box.top);			pane->SetPaneOrigin(p);			pane->UpdateVScrollBar();				}		else if (top < box.top + p.v) {					p.v = top;			if (top < box.bottom - box.top) p.v = 0;			pane->SetPaneOrigin(p);			pane->UpdateVScrollBar();				}			}}void ExptViewObject::GetRatText(short i,char *rat_text) {	char num_text[5],tag[32];		if (i+1 < 10) {		sprintf(num_text,"00%d",i+1);	}	else if ( 10 <= i+1 && i+1 <= 99) {		sprintf(num_text,"0%d",i+1);	}	else {		sprintf(num_text,"%d",i+1);	}	(wgtWindow->GetExpt())->GetTag(tag);	sprintf(rat_text,"%s%s",tag,num_text);}void ExptViewObject::SetRatBoxes(short i) {	short column_left;			column_left = 0;		subject.box.left = SUBJ_LEFT + column_left;	subject.box.right = subject.box.left + SUBJ_WIDTH;		subject.size = onWeight.size = offWeight.size = deltaWeight.size = EXPT_FONTSIZE;	subject.box.top = onWeight.box.top = offWeight.box.top = deltaWeight.box.top = ( i * EXPT_HEIGHT) + (2*EXPT_HEIGHT);	subject.box.bottom = onWeight.box.bottom = offWeight.box.bottom = deltaWeight.box.bottom = subject.box.top + EXPT_FONTSIZE;		subject.justify = teJustRight;	onWeight.justify = offWeight.justify = deltaWeight.justify = teJustRight;	deltaWeight.style = bold;	}void ExptViewObject::SetItemBoxes(short i) {	short column_left;			column_left = i * (EXPT_COLUMN_WIDTH);		onWeight.text[0] = '\0';	offWeight.text[0] = '\0';	deltaWeight.text[0] = '\0';		onWeight.box.left = ON_LEFT + column_left;	onWeight.box.right = onWeight.box.left + SMALLWGT_WIDTH;	offWeight.box.left = OFF_LEFT+ column_left;	offWeight.box.right = offWeight.box.left + SMALLWGT_WIDTH;	deltaWeight.box.left = DELTA_LEFT+ column_left;	deltaWeight.box.right = deltaWeight.box.left + SMALLWGT_WIDTH;				}void ExptViewObject::SetHiliteWeight(short r,short i) {	hiliteRat  = r;	hiliteItem = i;}void ExptViewObject::HiliteWeight(void) {	Rect hiliteBox;		if (hiliteRat == -1) return;		SetRatBoxes(hiliteRat); SetItemBoxes(hiliteItem);	hiliteBox = onWeight.box;	hiliteBox.top--;	hiliteBox.right = deltaWeight.box.right + WGT_TEXT_MARGIN;	FrameRect(&hiliteBox);}void ExptViewObject::Draw(Rect *updateRect,PaneObject *pane) {		Experiment *expt;		//SetPort(wgtWindow->GetWindowPtr());		expt =wgtWindow->GetExpt();	if ( expt == NULL) return;//	ClipRect(updateRect);		short i,j;	short right;	short rightEdge,bottomEdge;		EraseRect(updateRect);		DrawHeadings();		for (i=0;i<expt->GetNumRats();i++) {		SetRatBoxes(i);		GetRatText(i,subject.text);		subject.Draw();			for (j=0;j<expt->GetNumItems();j++) {			SetItemBoxes(j);			expt->GetItemText(i,j,onWeight.text,offWeight.text,deltaWeight.text);			onWeight.Draw();			offWeight.Draw();			deltaWeight.Draw();			}				if (expt->HasPreference()) {					SetItemBoxes(expt->GetNumItems());			expt->GetPrefScoreText(i,onWeight.text);			onWeight.Draw();					}					}		HiliteWeight();			rightEdge = (expt->GetNumItems() + 1) * EXPT_COLUMN_WIDTH;		PenPat(&(qd.ltGray));	for (i=3;i<expt->GetNumRats();i+=4) {			SetRatBoxes(i);			MoveTo(SUBJ_LEFT,subject.box.bottom);			LineTo(rightEdge,subject.box.bottom);	}	bottomEdge = (( expt->GetNumRats() + 1) * EXPT_HEIGHT) + (2*EXPT_HEIGHT);		MoveTo(ON_LEFT - (WGT_TEXT_MARGIN/2),0);	LineTo(ON_LEFT - (WGT_TEXT_MARGIN/2),bottomEdge);		SetRatBoxes(0);	for (j=0;j<expt->GetNumItems();j++) {		SetItemBoxes(j);		right = deltaWeight.box.right+WGT_TEXT_MARGIN;		while (right % 3 != 0) right++;		if (right % 2 != 0) right++;		MoveTo(right,0);		LineTo(right,bottomEdge);	}		PenNormal();	}unsigned long ExptViewObject::Print(TPrint **hPrint,TPPrPort printPort) {	char onstring[50],offstring[50],tag[10],name[50];	short numRats,numPages,ratHeight,ratTop;	Rect clipRect;		LabelObject title, heading;		TPrStatus	prStatus;	GrafPtr		savePort;			SetHiliteWeight(-1,-1);	numPages = 0;	SetOrigin(0,0);	Experiment *expt = wgtWindow->GetExpt();		numRats = expt->GetNumRats();	SetRatBoxes(numRats-1);	ratHeight = subject.box.bottom;		if (expt == NULL) return(0);		expt->GetName(name);	expt->GetTag(tag);		sprintf(title.text,"%s: %s",tag,name);				PrOpenPage(printPort,NULL);		title.justify = teJustLeft;	title.style = bold;	title.box.left = 30;	title.box.top = 20;	title.box.right = 540;	title.box.bottom = 40;	title.size = 18;	title.Draw();	DailyData *current_day = expt->GetCurrentDay();	Secs2TimeStr(current_day->onTime,onstring,SHORTDATE,HRCOLON  + SHOWNOSECS);	Secs2TimeStr(current_day->offTime,offstring,SHORTDATE,HRCOLON + SHOWNOSECS);	sprintf(heading.text,"Weighed On: %s",onstring);	heading.justify = teJustLeft;	heading.style = bold;	heading.box.left = 30;	heading.box.top = 45;	heading.box.right = 540;	heading.box.bottom = 65;	heading.size = 14;	heading.Draw();		if (!expt->WaitingForOff()) {		sprintf(heading.text,"Weighed Off: %s",offstring);		heading.justify = teJustLeft;		heading.style = bold;		heading.box.left = 30;		heading.box.top = 65;		heading.box.right = 540;		heading.box.bottom = 85;		heading.size = 14;		heading.Draw();	}			expt->GetComment(heading.text);		heading.justify = teJustLeft;		heading.style = bold;		heading.box.left = 30;		heading.box.top = 90;		heading.box.right = 540;		heading.box.bottom = 150;		heading.size = 12;		heading.Draw();		SetOrigin(0,-150);	Draw(NULL,NULL);		// tell it to print the page	PrClosePage(printPort);			numPages++;	if (numRats > 32) {				// then we need to draw on remaining pages		//start at 570, increment by 720				for (ratTop = 34 * 17; ratTop / 17 < numRats; ratTop += 40 * 17) {							clipRect.top = ratTop;			clipRect.bottom = ratTop + 720;			clipRect.left = 0;			clipRect.right = 612;			ClipRect(&clipRect);			PrOpenPage(printPort,NULL);						// print the page number			SetOrigin(0,0);			sprintf(heading.text,"%s, p. %ld",tag, numPages+1);			heading.justify = teJustRight;			heading.style = bold;			heading.box.left = 30;			heading.box.top = 0;			heading.box.right = 540;			heading.box.bottom = 14;			heading.size = 12;			heading.Draw();									SetOrigin(0,ratTop);			Draw(NULL,NULL);			// tell it to print the page			numPages++;			PrClosePage(printPort);								}				}				SetOrigin(0,0);	return(numPages);}WeightsWindow::WeightsWindow(char *name,Point maxSize) : WindowObject(name,maxSize,TRUE,TRUE,TRUE,TRUE) {	waiting_for_text = TRUE;	waiting_for_weight = FALSE;	text_len = 0;	curr_wgt_display = curr_weight;	//curr_weight+= 10;	expt = NULL;	pending = NULL;}Experiment *WeightsWindow::GetExpt(void) { return(expt); }void WeightsWindow::SetExpt(Experiment *e) { 	 char ename[100],etag[10],inputname[100]; 	 Point m = {5000,1000};	 expt = e;	 	if (expt != NULL) {		 m.v = (expt->GetNumRats() + 2) * EXPT_HEIGHT;	}	 	 expt_view->SetMaxSize(m);		 	 if (expt != NULL) {		 expt->GetName(ename);expt->GetTag(etag);		 sprintf(inputname,"%s: %s",etag,ename);		 input->SetExpt(inputname); 	 }	 else input->SetExpt("\0");} unsigned long WeightsWindow::GetUnWeighedItems(void) {	return(5);}void WeightsWindow::SetInputView(InputViewObject *i ) { input = i;input->wgtWindow = this;}void WeightsWindow::SetExptView(ExptViewObject *i ) { expt_view = i;expt_view->wgtWindow = this;}void WeightsWindow::KeyDown(char keypress, short modifiers) {	if (keypress == 16 ) {			sprintf(text_in,"%hd",modifiers);		}	if (keypress == CLEAR) {					Clear();			}	else {		if (waiting_for_text) {					if (keypress == RETURN || keypress == ENTER ) {				text_in[text_len] = '\0';				waiting_for_text = FALSE;				waiting_for_weight = TRUE;											}			else if (keypress == DELETEKEY ) {				if (text_len != 0) {					text_len--;					text_in[text_len] = '\0';				}			}			else {								text_in[text_len] = keypress;				text_len++;				text_in[text_len] = '\0';				if (text_len == 255) {					waiting_for_text = FALSE;				}			}						ClipRect(&input_pane_box);			input->SetTag(text_in);					}	}		if (!waiting_for_text) {		// return was pressed, so ready to get weight				if (ProcessTag()) {						// figure out the experiment, item, and subject number					ForceRedraw();					WaitForWeight();						// update weight of that item...										//ProcessWeight();				}				Clear();	}}void WeightsWindow::Clear(void) {			waiting_for_text = TRUE;			waiting_for_weight = FALSE;			weight_while_typing = FALSE;						text_len = 0;			text_in[text_len] = '\0';			input->SetTag(text_in);			if (expt == NULL) input->SetTag("\0");			ForceRedraw();}unsigned long numwLoops = 0;unsigned long numReads = 0;void WeightsWindow::OnceALoop(void) {	char wgt_text[50];		return;		//if (FrontWindow() != window) return;		//input->SetWeight(curr_wgt_text);	numwLoops++;	if (numwLoops == 5000) { 			 			numwLoops = 0; 		 		}			if (ReadBalance()) {					sprintf(wgt_text,"%.2f g",curr_weight); 	 		input->SetWeight(wgt_text); 		 		if (waiting_for_text) {  			weight_while_typing = TRUE; 		} 		 		/* 		if (pending != NULL) { 		 			ProcessWeight(pending->expt,pending->rat,pending->item); 			waiting_for_weight = FALSE; 			delete pending; 			pending = NULL; 			 			 		} 		numReads++; 		if (numReads == 100) { 			 			numReads = 0; 		 		} 		*/ 		}} void WeightsWindow::WaitForWeight(void) {  	char wgt_text[50]; 	unsigned long wait = 0; 	Boolean readflag = FALSE; 	double old_weight; 	unsigned long numReads; 	 	 	/* use for debugging purposes 	old_weight = curr_weight; 	ProcessWeight(expt,rat,item);	readflag = TRUE;	curr_weight += 10; 	return; 	*/ 	 	old_weight = curr_weight; 	/* 	if (weight_while_typing && SecsNow() - curr_weight_time < 2 && curr_weight > min_weight) { 	 		 		ProcessWeight(expt,rat,item); 		return; 	 	} */ 	numReads = 0; 	unsigned long startTime = SecsNow(); 	while (wait < 5 && !readflag) { 	 		 		if (ReadBalance()) {  	 			sprintf(wgt_text,"%.2f g",curr_weight); 	 			 			input->SetWeight(wgt_text); 			 			if (curr_weight_stable ) {	 			if ( curr_weight > min_weight) {	 				ProcessWeight(expt,rat,item);	 				readflag = TRUE;	 			}	  			} 			numReads++; 			wait = SecsNow() - startTime; 		} 		 		 	} 	  	// curr_weight += 10; //comment out in real program 	 	//waiting_for_weight = TRUE; 	//pending = new PendingWgt(expt,rat,item); 	 	  } PendingWgt::PendingWgt(Experiment *e,unsigned long r, ItemType *i) {	expt = e;	rat = r;	item = i;	time_spawned = SecsNow();}void WeightsWindow::ProcessWeight(Experiment *e,unsigned long r, ItemType *i) { 	SysBeep(0); }OnWeightsWindow::OnWeightsWindow(char *name, Point maxSize) : WeightsWindow (name,maxSize) {}void OnWeightsWindow::ProcessWeight(Experiment *e,unsigned long r, ItemType *i) {	if (curr_weight < min_weight || max_weight < curr_weight) {		SysBeep(0); SysBeep(0); 		return;		}  	e->SetOnWeight(r,i,curr_weight); 	expt_view->SetHiliteWeight(r,e->GetItemIndex(i)); 	SysBeep(0); }OffWeightsWindow::OffWeightsWindow(char *name, Point maxSize) : WeightsWindow (name,maxSize) {}void OffWeightsWindow::ProcessWeight(Experiment *e,unsigned long r, ItemType *i) {	if (curr_weight < min_weight || max_weight < curr_weight) {		SysBeep(0); SysBeep(0); 		return;		}  	e->SetOffWeight(r,i,curr_weight); 	expt_view->SetHiliteWeight(r,e->GetItemIndex(i)); 	SysBeep(0); }#define WRONGEXPTID 131#define NOTONEXPTID 132#define NOTOFFEXPTID 133#define UNKNOWNRATID 138#define UNKNOWNITEMID 139#define UNKNOWNEXPTID 140Boolean WeightsWindow::ProcessTag(void) {		Experiment *matchExpt;	char pText[256];		matchExpt = MatchTag2Expt(text_in);		if (matchExpt == NULL) {			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);		Alert(UNKNOWNEXPTID,0L);ResetAlrtStage();	    return(FALSE);				}	else {				if (GetExpt() == NULL ) {			// match tag to an experiment						SetExpt(matchExpt);				}		else if (matchExpt != GetExpt()) {					// beep louder!			// not the right expt			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);			     		Alert(WRONGEXPTID,0L);ResetAlrtStage();     		return(FALSE);				}			}		return(TRUE);	}Boolean OnWeightsWindow::ProcessTag(void) {		Experiment *matchExpt;	char pText[256];		matchExpt = MatchTag2Expt(text_in);		if (matchExpt == NULL) {			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);		Alert(UNKNOWNEXPTID,0L);ResetAlrtStage();	    return(FALSE);				}	else {						if (GetExpt() == NULL ) {			// match tag to an experiment			if (matchExpt->WaitingForOff()) {						// beep louder!				// not ready for on weights				strcpy(pText,text_in);				CtoPstr(pText);				ParamText((unsigned char *)pText,NULL,NULL,NULL);					     		Alert(NOTONEXPTID,0L);ResetAlrtStage();	     		AbortWeighing();	     		return(FALSE);								}			SetExpt(matchExpt);			matchExpt->SetWaitingForOff(TRUE);				}		else if (matchExpt != GetExpt()) {					// beep louder!			// not the right expt			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);			     		Alert(WRONGEXPTID,0L);ResetAlrtStage();     		return(FALSE);				}				// extract the rat id and the tag id				rat = expt->Tag2Rat(text_in);			if (rat == -1) {				strcpy(pText,text_in);				CtoPstr(pText);				ParamText((unsigned char *)pText,NULL,NULL,NULL);				Alert(UNKNOWNRATID,0L);ResetAlrtStage();						}		else {							// scroll window to show the rat's line				expt_view->FixOrigin(rat);									}		item = expt->Tag2Item(text_in);					if (item == NULL) {				strcpy(pText,text_in);				CtoPstr(pText);				ParamText((unsigned char *)pText,NULL,NULL,NULL);				Alert(UNKNOWNITEMID,0L);ResetAlrtStage();						}					}		if (rat == -1 || item == NULL || matchExpt == NULL) return(FALSE);				return(TRUE);	}Boolean OffWeightsWindow::ProcessTag(void) {		Experiment *matchExpt;	char pText[256];		matchExpt = MatchTag2Expt(text_in);		if (matchExpt == NULL) {			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);		Alert(UNKNOWNEXPTID,0L);ResetAlrtStage();	    return(FALSE);				}	else {			if (!matchExpt->WaitingForOff()) {					// beep louder!			// not ready for off weights...			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);			     		Alert(NOTOFFEXPTID,0L);ResetAlrtStage();     		AbortWeighing();     		return(FALSE);					}			if (GetExpt() == NULL ) {			// match tag to an experiment						SetExpt(matchExpt);				}		else if (matchExpt != GetExpt()) {					// beep louder!			// not the right expt			strcpy(pText,text_in);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);			     		Alert(WRONGEXPTID,0L);ResetAlrtStage();     		return(FALSE);				}						// extract the rat id and the tag id				rat = expt->Tag2Rat(text_in);			if (rat == -1) {				strcpy(pText,text_in);				CtoPstr(pText);				ParamText((unsigned char *)pText,NULL,NULL,NULL);				Alert(UNKNOWNRATID,0L);ResetAlrtStage();						}			else {							// scroll window to show the rat's line				expt_view->FixOrigin(rat);									}		item = expt->Tag2Item(text_in);					if (item == NULL) {				strcpy(pText,text_in);				CtoPstr(pText);				ParamText((unsigned char *)pText,NULL,NULL,NULL);				Alert(UNKNOWNITEMID,0L);ResetAlrtStage();						}					}		if (rat == -1 || item == NULL) return(FALSE);				return(TRUE);		} Boolean  WeightsWindow::GoAway(Point globalPt) {		FinishWeighing();		return(TRUE);}Boolean WeightsWindow::Close(void) {		FinishWeighing();	return(TRUE);}#define FINISHWEIGHTS 142Boolean WeightsWindow::OKToFinish(void) {		short finish;char expText[100],itemText[20];		unsigned long unweighed;				expt->GetName(expText);						unweighed = GetUnWeighedItems();			if (unweighed > 0) {				sprintf(itemText,"%lu",unweighed);				CtoPstr(expText);				CtoPstr(itemText);				ParamText((unsigned char *)expText,(unsigned char *)itemText,NULL,NULL);				finish = Alert(FINISHWEIGHTS,0L);ResetAlrtStage();				if (finish == 1) return (FALSE);						//DON'T FINISH -- continue weighing							}						return(TRUE); // OK TO FINISH}		Boolean WeightsWindow::FinishWeighing(void) {// tell experiment to save the weights	if (!OKToFinish()) return(FALSE);	Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}Boolean OnWeightsWindow::FinishWeighing(void) {	if (!OKToFinish()) return(FALSE);	// tell experiment to save the on weights	if (expt != NULL) {		expt->SaveOnWeights();		Print();		expt->ClearCurrentDay();	}	Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}Boolean OffWeightsWindow::FinishWeighing(void) {	if (!OKToFinish()) return(FALSE);		// tell experiment to save the off weights	if (expt != NULL) {		expt->SaveOffWeights();		Print();		expt->ClearCurrentDay();	}	Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}Boolean WeightsWindow::AbortWeighing(void) {// tell experiment to abort the weights	//if (expt != NULL) expt->AbortWeighing();		Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}Boolean OnWeightsWindow::AbortWeighing(void) {// tell experiment to abort the weights	if (expt != NULL) expt->AbortOnWeighing();	Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}Boolean OffWeightsWindow::AbortWeighing(void) {// tell experiment to abort the weights	if (expt != NULL) expt->AbortOffWeighing();	Clear();	SetExpt(NULL);	HideWindow(GetWindowPtr());	return(TRUE);}unsigned long OnWeightsWindow::GetUnWeighedItems(void) {	if (expt != NULL) return(expt->GetUnWeighedOnItems());	else return(0);}unsigned long OffWeightsWindow::GetUnWeighedItems(void) {	if (expt != NULL) return(expt->GetUnWeighedOffItems());	else return(0);}unsigned long WeightsWindow::Print(void) {	TPPrPort printPort;	Object *pane;	short copies;	TPrStatus	prStatus;	GrafPtr		savePort;	unsigned long numPages = 0;		if (!printable) return (numPages);	if (hPrint==NULL) 		PrintDefault(hPrint = (TPrint **) NewHandle( sizeof( TPrint )));	SetCursor(&Watch);	BeginUpdate(window);	SetPort(window);	ClipRect(&(window->portRect));			PrOpen();	InitCursor();	if (PrJobDialog(hPrint) == 0) return(numPages);	SetCursor(&Watch);		for (copies=PrintHowMany(hPrint); copies>0; copies--) {			GetPort(&savePort);		printPort = PrOpenDoc( hPrint, 0L, 0L );				SetPort((GrafPort *)printPort);	// just print the expt view...		SetOrigin(0,0);		ClipRect(&(window->portRect));				numPages += expt_view->Print(hPrint,printPort);					SetPort(savePort);		PrCloseDoc( printPort );		PrPicFile( hPrint, 0L, 0L, 0L, &prStatus );				}	return(numPages);	}