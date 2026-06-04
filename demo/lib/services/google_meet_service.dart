import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleMeetService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarEventsScope],
    clientId: '971858551246-4m66iq79g55hk8rdl6s5sim3974bj46l.apps.googleusercontent.com',
  );

  Future<String?> createMeeting() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return null;
      }

      final authClient = await _googleSignIn.authenticatedClient();

      if (authClient == null) {
        return null;
      }

      final calendarApi = calendar.CalendarApi(authClient);

      final event = calendar.Event()
        ..summary = 'Phỏng vấn ViecCuaTui'
        ..description = 'Cuộc họp phỏng vấn trực tuyến'
        ..start = (calendar.EventDateTime()
          ..dateTime = DateTime.now().add(const Duration(minutes: 10)).toUtc()
          ..timeZone = 'UTC')
        ..end = (calendar.EventDateTime()
          ..dateTime = DateTime.now().add(const Duration(hours: 1, minutes: 10)).toUtc()
          ..timeZone = 'UTC')
        ..conferenceData = (calendar.ConferenceData()
          ..createRequest = (calendar.CreateConferenceRequest()
            ..requestId = DateTime.now().millisecondsSinceEpoch.toString()
            ..conferenceSolutionKey = (calendar.ConferenceSolutionKey()
              ..type = 'hangoutsMeet')));

      final createdEvent = await calendarApi.events.insert(
        event,
        'primary',
        conferenceDataVersion: 1,
      );

      return createdEvent.hangoutLink;
    } catch (e) {
      return null;
    }
  }
}