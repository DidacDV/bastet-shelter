def magic_link_email(name: str, magic_link_url: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0; background-color:#ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
      <table width="100%" cellpadding="0" cellspacing="0" style="padding: 30px 15px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:500px; text-align: left;">

              <tr>
                <td style="padding-bottom: 20px; border-bottom: 2px solid #f0f0f5;">
                  <h2 style="margin:0; color:#3B3686; font-size: 22px; font-weight: bold;">Bastet Shelter</h2>
                </td>
              </tr>

              <tr>
                <td style="padding: 30px 0;">
                  <p style="margin:0 0 16px; font-size:16px;">Hi {name},</p>

                  <p style="margin:0 0 24px; font-size:16px; line-height:1.5;">
                    Here is your link to access the adoption portal. Just click the button below to log in.
                  </p>

                  <p style="margin:0 0 30px;">
                    <a href="{magic_link_url}"
                       style="display:inline-block; background-color:#3B3686; color:#ffffff;
                              text-decoration:none; font-size:16px; font-weight:bold;
                              padding:12px 24px; border-radius:6px;">
                      Log in to your account
                    </a>
                  </p>

                  <p style="margin:0 0 8px; font-size:14px; color:#555555;">
                    Or copy and paste this URL into your browser:
                  </p>
                  <p style="margin:0; font-size:14px; word-break:break-all;">
                    <a href="{magic_link_url}" style="color:#3B3686;">{magic_link_url}</a>
                  </p>
                </td>
              </tr>

              <tr>
                <td style="padding-top:25px; border-top:2px solid #f0f0f5;">
                  <p style="margin:0 0 16px; font-size:13px; color:#777777; line-height:1.5;">
                    This link is only valid for 30 days and can be used once. If you didn't ask for this email, you can safely ignore it.
                  </p>
                  <p style="margin:0; font-size:13px; color:#777777;">
                    Best,<br>
                    The Bastet Shelter Team
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """


def adoption_request_received_email(adoptant_name: str, animal_name: str, frontend_url: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0; background-color:#ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
      <table width="100%" cellpadding="0" cellspacing="0" style="padding: 30px 15px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:500px; text-align: left;">

              <tr>
                <td style="padding-bottom: 20px; border-bottom: 2px solid #f0f0f5;">
                  <h2 style="margin:0; color:#3B3686; font-size: 22px; font-weight: bold;">Bastet Shelter</h2>
                </td>
              </tr>

              <tr>
                <td style="padding: 30px 0;">
                  <p style="margin:0 0 16px; font-size:16px;">Hi {adoptant_name},</p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    Thank you for submitting your adoption application for <strong>{animal_name}</strong>. We have received your request and our team will review it shortly.
                  </p>

                  <p style="margin:0 0 24px; font-size:16px; line-height:1.5;">
                    You can visit Bastet Shelter at any time to track the progress of your application. We will keep you updated by email as your adoption process moves forward.
                  </p>

                  <p style="margin:0 0 30px;">
                    <a href="{frontend_url}"
                       style="display:inline-block; background-color:#3B3686; color:#ffffff;
                              text-decoration:none; font-size:16px; font-weight:bold;
                              padding:12px 24px; border-radius:6px;">
                      Go to Bastet Shelter
                    </a>
                  </p>
                </td>
              </tr>

              <tr>
                <td style="padding-top:25px; border-top:2px solid #f0f0f5;">
                  <p style="margin:0; font-size:13px; color:#777777;">
                    Best,<br>
                    The Bastet Shelter Team
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """


def adoption_request_shelter_email(
    shelter_name: str,
    adoptant_name: str,
    adoptant_email: str,
    animal_name: str,
    frontend_url: str,
) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0; background-color:#ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
      <table width="100%" cellpadding="0" cellspacing="0" style="padding: 30px 15px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:500px; text-align: left;">

              <tr>
                <td style="padding-bottom: 20px; border-bottom: 2px solid #f0f0f5;">
                  <h2 style="margin:0; color:#3B3686; font-size: 22px; font-weight: bold;">Bastet Shelter</h2>
                </td>
              </tr>

              <tr>
                <td style="padding: 30px 0;">
                  <p style="margin:0 0 16px; font-size:16px;">Hi {shelter_name} team,</p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    A new adoption application has been submitted for <strong>{animal_name}</strong>.
                  </p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    <strong>Adoptant:</strong> {adoptant_name}<br>
                    <strong>Email:</strong> {adoptant_email}
                  </p>

                  <p style="margin:0 0 24px; font-size:16px; line-height:1.5;">
                    You can review the application and manage the adoption process from the Bastet Shelter app.
                  </p>

                  <p style="margin:0 0 30px;">
                    <a href="{frontend_url}"
                       style="display:inline-block; background-color:#3B3686; color:#ffffff;
                              text-decoration:none; font-size:16px; font-weight:bold;
                              padding:12px 24px; border-radius:6px;">
                      Go to Bastet Shelter
                    </a>
                  </p>
                </td>
              </tr>

              <tr>
                <td style="padding-top:25px; border-top:2px solid #f0f0f5;">
                  <p style="margin:0; font-size:13px; color:#777777;">
                    Best,<br>
                    The Bastet Shelter Team
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """


def adoption_completed_email(adoptant_name: str, animal_name: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0; background-color:#ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
      <table width="100%" cellpadding="0" cellspacing="0" style="padding: 30px 15px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:500px; text-align: left;">

              <tr>
                <td style="padding-bottom: 20px; border-bottom: 2px solid #f0f0f5;">
                  <h2 style="margin:0; color:#3B3686; font-size: 22px; font-weight: bold;">Bastet Shelter</h2>
                </td>
              </tr>

              <tr>
                <td style="padding: 30px 0;">
                  <p style="margin:0 0 16px; font-size:16px;">Hi {adoptant_name},</p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    Great news! Your adoption process for <strong>{animal_name}</strong> has been officially completed. 
                  </p>

                  <p style="margin:0 0 24px; font-size:16px; line-height:1.5;">
                    We are so incredibly happy for both of you. Thank you for opening your home and your heart to a shelter animal. If you ever have any questions as {animal_name} settles in, please don't hesitate to reach out to us.
                  </p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    Wishing you years of joy together!
                  </p>
                </td>
              </tr>

              <tr>
                <td style="padding-top:25px; border-top:2px solid #f0f0f5;">
                  <p style="margin:0; font-size:13px; color:#777777;">
                    Best,<br>
                    The Bastet Shelter Team
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """


def adoption_rejected_email(adoptant_name: str, animal_name: str, reason: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0; background-color:#ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
      <table width="100%" cellpadding="0" cellspacing="0" style="padding: 30px 15px;">
        <tr>
          <td align="center">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:500px; text-align: left;">

              <tr>
                <td style="padding-bottom: 20px; border-bottom: 2px solid #f0f0f5;">
                  <h2 style="margin:0; color:#3B3686; font-size: 22px; font-weight: bold;">Bastet Shelter</h2>
                </td>
              </tr>

              <tr>
                <td style="padding: 30px 0;">
                  <p style="margin:0 0 16px; font-size:16px;">Hi {adoptant_name},</p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    Thank you for your interest in adopting <strong>{animal_name}</strong>. We truly appreciate the time you took to apply.
                  </p>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    Unfortunately, we are unable to move forward with your adoption application at this time. Here is the context from our team:
                  </p>

                  <blockquote style="margin: 0 0 24px 0; padding: 12px 16px; background-color: #f8f9fa; border-left: 4px solid #3B3686; font-size: 15px; color: #555555; line-height: 1.5;">
                    "{reason}"
                  </blockquote>

                  <p style="margin:0 0 16px; font-size:16px; line-height:1.5;">
                    We know this might be disappointing news, but we make all decisions with the specific needs of each animal in mind. Thank you again for wanting to rescue.
                  </p>
                </td>
              </tr>

              <tr>
                <td style="padding-top:25px; border-top:2px solid #f0f0f5;">
                  <p style="margin:0; font-size:13px; color:#777777;">
                    Best,<br>
                    The Bastet Shelter Team
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """