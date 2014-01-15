# Description:
#   Plugin for HUBOT that finds email address based on first name, last name and domain. It uses Rapportive API to check if email is registered with services like LinkedIn, Facebook etc.
#
# Commands:
#   hubot find email of <first_name> <last_name> from <domain> - Tries to find emails
#
# Author:
#   Pawel Smoczyk - https://github.com/smoku

request = require "request"

formats = [
  "{first_name}.{last_name}",
  "{first_name}{last_name}",
  "{first_name_letter}{last_name}",
  "{first_name_letter}.{last_name}",
  "{first_name}",
  "{last_name}",
  "{first_name}-{last_name}",
  "{first_name}_{last_name}"
]

module.exports = (robot) ->
  robot.respond /find email of (\S*) (\S*) from (.*)/i, (msg) ->
    firstName = msg.match[1].trim().toLowerCase()
    lastName = msg.match[2].trim().toLowerCase()
    domain = msg.match[3].trim()
    
    msg.send "On it!"
    
    request "https://rapportive.com/login_status?user_email=whatever.rand.23141@gmail.com", (error, response, body) ->
      if !error and response.statusCode == 200
        sessionToken = JSON.parse(body)["session_token"]
        headers = { "X-Session-Token": sessionToken }
        found = false
        formats.forEach (format) ->
          targetEmail = format.replace(/\{first_name\}/g, firstName).replace(/\{last_name\}/g, lastName).replace(/\{first_name_letter\}/g, firstName[0]) + "@" + domain
          request { url: "https://profiles.rapportive.com/contacts/email/#{targetEmail}", headers: headers }, (error, response, body) ->
            contact = JSON.parse(body).contact
            if contact["first_name"].length != 0 and contact["last_name"].length != 0
              found = true
              msg.send "Found it! Email \"#{targetEmail}\" is valid."
        setTimeout (->
          unless found
            msg.send "Sorry, I did my best but I could not find email address :("
        ), 8000