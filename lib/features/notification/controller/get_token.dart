import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

Future<String> getAccessToken() async {
  // Thay đổi nội dung dưới đây bằng thông tin của Service Account của bạn.
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "da-gr1",
    "private_key_id": "519387c623227fdebffb175005c7616a77941cea",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDIh2ZmR8677SaI\nHNvDL7gMl9pDKA5cjsTYt/QsZituEC2FEc3RTLCmKKWq/v2xtvn9zYXr1t7DM6+U\nM+W8ewVQKPWqSKHTnHbJyZT1SZ42myrFrGvtv4Ur5EUr9N+c/ZvdqHwvCV6jawcf\niyiuecWYPfyvCtJ/gljukJToZn0YvBL2NcBAawBo8c595gCRqbvYGSpuCH+YqR+E\nDASeOjDhAxUZdJ6byrJEJeuG8TzUrb4v7KJZ0qh3atYG2RniEdkOncw3ymdnoI/F\n4neo6iSkb0cicsMsbZj5Xpq8AqrI0ZrdtbhhhiO/qxgENLjTj0A/gdKB1OuNjM10\nt1f6/TjDAgMBAAECggEAFxyv+zLki3liWwbEd4Ms+dqYr+vSd+2Gl5ngHSvrboST\n0oYCTFDD/Wqq6YH5OH3n405IVK3Pv/zZjEHNBUPCkYIfCnDTogGjGU/QCNNi1lVd\nASqFyAGudigZpt7S1RPP3qTYJ02zqC8iQ4r09eMYGJtwX7ZmG4co+9oTJ5QEcBCs\n/FLsTA8+Ahh+az+HznIh4aaEPa7wM4N+gvGW2xS/Kg9mR0BmKbUNrI0KbimI4W+8\nKd0uhmOMGUqBLGURcpnpLPF7/LQYYyJtyETwS5iuJ3YRWArFj6KoWoO4nPKzhPCo\nkTdHGMipFgk/RmnMO5phub3vythn+rIyEThqqb4DKQKBgQDmiZDkbXTLKlE+R5f4\n6RjC5mlfJAvZers2cVOxunB2IHhULPpW1QWc0LrRIJAytgu3VGB+Qw7hI9KKBF4I\nivJRQiCdPLdePDFsbG749nNVn+dYioPRPqrNJyzOVIWxfaTauMpg7FOgNxpWV0BF\nuCW3bwDbyrT3hmTwSEWQOPAVGQKBgQDerViZOku7J95y55flDlPsMPc5abQOmzPy\nT4j3lIMbq+8LU9uesBJ2V+QhbPAyMopQ9UsXAR9e+tiogNIBRR1Vx57BZybb/AJU\n/m2HHjTL3GmsZkc+/AFCO348kAu1ktDJGImFG4/1EEXhJ8rcFu9GwW73VTA6JWo7\nT3Aj+Lq8OwKBgQDazWv4ca5s+S/8tUSW2N1IdhlCVFruwZ6X8H1n7LS6WNz7v2im\nKy5VhIIa5BYYG1IJYQroK0sfAbnchoKdBwsvdlyv/6Vlyil6Z3v3zSjv9oFDNswf\nN6QybGEJP41YRRDHCqYB0asZH9NeaRc2VK1vaOpesQiK+UIqD93+IRw0WQKBgQCn\nlTn6h377KTQmsdkEz9WlCezlToHuBCwCDo18Fk7dgnXyxnegY85hNiBAb6YNgS/L\nYe/TLksXxh1MIzbpMcS0C/mUgDckk/KFWL3BVKBTVFxLHOY9ppaj6/ZDSf0l94od\n7dOBU47x1f9hRftLzA7j5yvGBFy5RfM/E7fHuqd+hQKBgDoqYGSOAUBwfPhgypV0\nuvIw/mtBFAVxU04S7cdqWrT1vbxzJoDMQWzYL4ufa9TZRolUpvdK6q2P38EIdyXC\nRrTLd1s9/+8pMFEMS5y0WRkpToAs/CFaBH4WN56FijyaFijUmvwuuuKDd5WptZLe\n2q5aTJW8/0VsYT+Xm/S97UnW\n-----END PRIVATE KEY-----\n",
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
