import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

Future<String> getAccessToken() async {
  // Thay đổi nội dung dưới đây bằng thông tin của Service Account của bạn.
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "da-gr1",
    "private_key_id": "d92e9677b4876aa17282278f40d91140bdc87dd6",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQCXOGdvRri/Ya57\nNiHG2rRrQBzhLCx57f09kSrKfBIuAUQ4CeXzuGLHISJXHRd8y3QfrZCE26Xyrmoh\nyOwcz3bKhfa0976fhyddc+UAfwqOK7iaC62AITnB9f47IKszVOFuWWha/2KYKX7B\nTwCObjLE9VadlrbeSF24+NfBOUmOWNoDl8GuLSquvgTjlr576wBKHMwcnwYtXAO9\ndIK9nUD71EglxYDr5/kMVsSGfeo/PU2Ibywml46vAVyWPp5GE3EavS5JRYTkY02m\nAChfxKTOWCK3SfUxZh+5p1LWF96g50g1A3XODe1cp3hoSScl4wME/iGAi+GTZf9W\n7ctpHsoRAgMBAAECggEACjkePikI9PKyeeTKrX6XnHm01YnsZq5lm48SRBRnx19I\nQs4qyeFCINp5dCLJWkfjciQ7J4THoUS4vT0diUPwuffBrI0tbjU4mhEP/xzguPIa\nBIAJmwHtKxv7s6+dbHtA02gfZIU1sgMwtkO4u+hMbcqZZwVmzunvPB00TWry6BRL\nDmrno73POsLTt2Azq5lQkHHqQewEG9kvQI/xFE8xdeJ02cOAB1tT6qhU3qXvJJEK\nRXEJyLWAnM8QhukL/n8/MVirBYN/rqiD15XosQcY6uoGtSQeA/VWD4IE0J4wSGhV\n9jreqASpdiKimbkjzr6LQWrGsOVEPqa+F8L/IPMDiQKBgQC/t2yKbZW4YEBwEMsY\nJEA8P8X73wrQsYJyzJAc8LyD/9KdI2cJwt8X6O+y0qg615jJQ0V8eH2c0aL1tiJ0\nbWaW7zvtZ6W2WkBd1a+IUhigWLMUphqyDcpfvIRiKOpfxvKEfMVMn7sz+Ef3g9jA\nyNWvjlvcgaprcrjJ2jZv/ioUowKBgQDJ7N3R4n2vuAsyu9H2MJ3c8wjAu1e8Yk1g\ngK4FtI+133fC95XIEb6/elsgr24SgrCV7FHt+17CVbPfY+Puo74jYnhmaVyMIfSR\naUx3LF+vOX+m0gpydxBuooQKwaPX+vRH6+Zh75zxuR99Z6HJs+7zOFhFehIlShbe\n+BaxWTvduwKBgAMnSzvDrbDItIajYBPXlM7o5aLM+mqQYOrufnhbZV5ueNJo4KsC\nb5T/GeJBIM9G+JZm6t+vQ7GuqRWNl2d+3S8iZEP1bn5fYaupdiex4gHRM7DlQo8n\nNur4ON08ew50QUz4mG44OmYScWya2JfjNdCbcNthrqHx0yRO2JJjBeItAn8l3EO7\nFrx6Ngfje1Pi1TrEMs1xVa8do1Dex0HZ0AEiGMRbyhBLcwhQ3qA3gK0iy15Qvf6e\noIMj7O3M9O3H0OvVtqDckuTHYZZ5rUSpE6jdMeq9XKSY0bpDBDW9zpDp7iPfWFva\nARNsP0moOcYcC6DB+c6TOFAurbWcGOgoWJLhAoGBAIuwfONEiAMsfQ+iffwejxDE\nM3OqodpLGjbiZVCAyA+DdRYWKvQNQoDdJ9JZyXTRYDxQ7WZvjgs1uSeTq82Ln1NE\nCl3lLN6Kf66ymMA9vUc+JQd3f5K8OfEQXG5T96Z9UiUsw+x2E6sAgFdH9D5RtQxa\njPu7FzkQ5fjvnV8SUzrr\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-6ecm4@da-gr1.iam.gserviceaccount.com",
    "client_id": "113624455504852943452",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-6ecm4%40da-gr1.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // clientViaServiceAccount sẽ tự động lấy (và làm mới) token cho bạn.
  final authClient = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  return authClient.credentials.accessToken.data;
}
