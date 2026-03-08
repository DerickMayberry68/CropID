enum SprayPlanSaveState {
  idle,
  saving,
  saved,
  failed,
}

extension SprayPlanSaveStateExt on SprayPlanSaveState {
  bool get isTerminal =>
      this == SprayPlanSaveState.saved || this == SprayPlanSaveState.failed;

  bool get canRetry => this == SprayPlanSaveState.failed;
}
