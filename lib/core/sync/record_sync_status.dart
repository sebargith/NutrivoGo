enum RecordSyncStatus {
  pending('pending'),
  synced('synced'),
  failed('failed');

  const RecordSyncStatus(this.storageValue);

  final String storageValue;

  static RecordSyncStatus fromStorage(String value) {
    return RecordSyncStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => RecordSyncStatus.pending,
    );
  }
}
