// BarOrders#include "BarObjects.hpp"#include "Weights.hpp"#include "ReadBalance.hpp"#include "BarOrders.hpp"extern WeightsWindow *onWeightsWindow;extern WeightsWindow *offWeightsWindow;void InstallBarOrders(void);Experiment *ChooseExpt(void);void InstallWeightOrders(WeightsWindow *weightsWindow);void InstallBarOrders(void) {	SaveCommand *s = new SaveCommand(&DefaultInterpretor);	SaveAsCommand *sv = new SaveAsCommand(&DefaultInterpretor);	CloseCommand *c = new CloseCommand(&DefaultInterpretor);	PageSetUpCommand *ps = new PageSetUpCommand(&DefaultInterpretor);	PrintCommand *p = new PrintCommand(&DefaultInterpretor);	CutCommand *cu = new CutCommand(&DefaultInterpretor);	CopyCommand *cp = new CopyCommand(&DefaultInterpretor);	PasteCommand *pt = new PasteCommand(&DefaultInterpretor);	DuplicateCommand *d = new DuplicateCommand(&DefaultInterpretor);	TileCommand *t = new TileCommand(&DefaultInterpretor);	StackCommand *st = new StackCommand(&DefaultInterpretor);	PrintAllCommand *pa = new PrintAllCommand(&DefaultInterpretor);	UndoCommand *ud = new UndoCommand(&DefaultInterpretor);			NewExptCommand *ne = new NewExptCommand(&DefaultInterpretor);	EditExptCommand *ee = new EditExptCommand(&DefaultInterpretor);	OnWeightsCommand *on = new OnWeightsCommand(&DefaultInterpretor);		OffWeightsCommand *off = new OffWeightsCommand(&DefaultInterpretor);		QuitBarCommand *quit = new QuitBarCommand(&DefaultInterpretor);		SetMinMaxCommand *minmax = new SetMinMaxCommand(&DefaultInterpretor);	TareCommand *tare = new TareCommand(&DefaultInterpretor);	VeryUnstableCommand *vu = new VeryUnstableCommand(&DefaultInterpretor);	UnstableCommand *us = new UnstableCommand(&DefaultInterpretor);	StableCommand *stable = new StableCommand(&DefaultInterpretor);	VeryStableCommand *vs = new VeryStableCommand(&DefaultInterpretor);		}NewExptCommand::NewExptCommand(InterpretorObject *o):CommandObject(o,"New Expt...","Create New Experiment","ne"){}	void NewExptCommand::DoCommand(void) { 	Experiment *expt = new Experiment();	expt->SetNewExptDefaults();	if (EditExperiment(expt)) {				expt->Save();		allExpts->AddMember(expt);		return;		}		else {			delete expt;		}}EditExptCommand::EditExptCommand(InterpretorObject *o):CommandObject(o,"Edit Expt...","Edit An Experiment","ne"){}	#define CANTEDITEXPTID 145void EditExptCommand::DoCommand(void) { 	Experiment *expt = ChooseExpt();	if (expt != NULL) {			if (expt->AmIWaitingForOff()) {					// can't edit experiment when waiting for off weights...			char pText[256];			expt->GetName(pText);			CtoPstr(pText);			ParamText((unsigned char *)pText,NULL,NULL,NULL);			InitCursor();			Alert(CANTEDITEXPTID,0L);ResetAlrtStage();				}		else {			if (EditExperiment(expt)) {				expt->ReplaceCumulFile();				expt->Save();			}		}	}	}OnWeightsCommand::OnWeightsCommand(InterpretorObject *o):CommandObject(o,"On Weights...","Create New Experiment","ne"){}	void OnWeightsCommand::DoCommand(void) { 	onWeightsWindow->SetExpt(NULL);	ShowWindow(onWeightsWindow->GetWindowPtr());	BringToFront(onWeightsWindow->GetWindowPtr());	SelectWindow(onWeightsWindow->GetWindowPtr());	}OffWeightsCommand::OffWeightsCommand(InterpretorObject *o):CommandObject(o,"Off Weights...","Create New Experiment","ne"){}	void OffWeightsCommand::DoCommand(void) { 	offWeightsWindow->SetExpt(NULL);	ShowWindow(offWeightsWindow->GetWindowPtr());	BringToFront(offWeightsWindow->GetWindowPtr());	SelectWindow(offWeightsWindow->GetWindowPtr());	}#define ABORTWEIGHTS 141AbortWeightsCommand::AbortWeightsCommand(InterpretorObject *o):CommandObject(o,"Abort Weighing","Abort Weighing","ne"){}	void AbortWeightsCommand::DoCommand(void) { 		short abort;	char expText[100];				Experiment *expt;				expt = ((WeightsWindow *)owner)->GetExpt();								if (expt != NULL) {					expt->GetName(expText);					CtoPstr(expText);					ParamText((unsigned char *)expText,NULL,NULL,NULL);					abort = Alert(ABORTWEIGHTS,0L);ResetAlrtStage();					if (abort == 1) return;				}								((WeightsWindow *)owner)->AbortWeighing();}#define FINISHWEIGHTS 142FinishWeightsCommand::FinishWeightsCommand(InterpretorObject *o):CommandObject(o,"Finish Weighing","Finish Weighing","ne"){}	void FinishWeightsCommand::DoCommand(void) { 			((WeightsWindow *)owner)->FinishWeighing();}							void InstallWeightOrders(WeightsWindow *weightsWindow) {	FinishWeightsCommand *fw = new FinishWeightsCommand(weightsWindow);	AbortWeightsCommand *aw = new AbortWeightsCommand(weightsWindow);	}QuitBarCommand::QuitBarCommand(InterpretorObject *o):CommandObject(o,"Quit","Quit Weighing","q"){}	void QuitBarCommand::DoCommand(void) { 	 CloseBalance(); 	if (CloseGlobalWindows()) {			ExitToShell();	}}void SetMinMaxWeights(void);SetMinMaxCommand::SetMinMaxCommand(InterpretorObject *o):CommandObject(o,"Min/Max Weights...","define min-max weights","m"){}	void SetMinMaxCommand::DoCommand(void) { 	SetMinMaxWeights();}TareCommand::TareCommand(InterpretorObject *o):CommandObject(o,"Tare","tare the balance","t"){}	void TareCommand::DoCommand(void) { Tare();}VeryUnstableCommand::VeryUnstableCommand(InterpretorObject *o):CommandObject(o,"Very Unstable","set balance for very unstable","vu"){}	void VeryUnstableCommand::DoCommand(void) { SetVeryUnstable();}UnstableCommand::UnstableCommand(InterpretorObject *o):CommandObject(o,"Unstable","set balance for unstable","u"){}	void UnstableCommand::DoCommand(void) { SetUnstable();}StableCommand::StableCommand(InterpretorObject *o):CommandObject(o,"Stable","set balance for stable","s"){}	void StableCommand::DoCommand(void) { SetStable();}VeryStableCommand::VeryStableCommand(InterpretorObject *o):CommandObject(o,"Very Stable","set balance for very stable","vs"){}	void VeryStableCommand::DoCommand(void) { SetVeryStable();}