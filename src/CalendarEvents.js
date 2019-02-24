// https://developers.google.com/calendar/v3/reference/events/list
exports.listEventsImpl = function (options) {
  return function (client) {
    return function () {
      const google = require('googleapis').google;

      const calendar = google.calendar({ version: 'v3', auth: client });
      return new Promise(function (resolve, reject) {
        calendar.events.list(options, function (error, result) {
          if (error)
            reject(error);
          else
            resolve(result);
        });
      });
    };
  };
};

exports.newClientImpl = function (credentialsContent) {
  return function (tokenContent) {
    return function () {
      const google = require('googleapis').google;

      const installed = JSON.parse(credentialsContent).installed;
      const client_secret = installed.client_secret;
      const client_id = installed.client_id;
      const redirect_uris = installed.redirect_uris;
      const oAuth2Client = new google.auth.OAuth2(
        client_id, client_secret, redirect_uris[0]);
      oAuth2Client.setCredentials(JSON.parse(tokenContent));
      return oAuth2Client;
    };
  };
};
