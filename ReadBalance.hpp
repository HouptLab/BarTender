extern double curr_weight;extern unsigned long curr_weight_time;extern char curr_wgt_text[100];extern Boolean curr_weight_stable;OSErr OpenBalance(void);void CloseBalance(void);Boolean ReadBalance(void);void StopReadBalance(void);void Tare(void);void SetVeryStable(void);void SetStable(void);void SetUnstable(void);void SetVeryUnstable(void);