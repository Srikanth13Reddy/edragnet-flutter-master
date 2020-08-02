class CrimeDetails {
  final String crimeId;
  final String crimeName;
  final String crimeDescription;
  final String occurrenceAddress;
  final String occurrenceLatitude;
  final String occurrenceLongitude;
  final String timeOfOccurrence;
  final String dateOfOccurence;
  final String notificationId;
  final String severity;

  CrimeDetails(
    this.crimeId,
    this.crimeName,
    this.crimeDescription,
    this.occurrenceAddress,
    this.occurrenceLatitude,
    this.occurrenceLongitude,
    this.timeOfOccurrence,
    this.dateOfOccurence,
    this.notificationId,
    this.severity,
  );
}
