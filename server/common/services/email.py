def send_verification_email(to_address: str, subject: str, html_message: str):
    pass

    # try:
    #     mailjet = Client(auth=(settings.MJ_APIKEY_PUBLIC, settings.MJ_APIKEY_PRIVATE), version='v3.1')
    #     receiver_name = to_address.split("@")[0]
    #     data = {
    #         'Messages': [
    #             {
    #                 "From": {
    #                     "Email": "killerrazerblade@gmail.com",
    #                     "Name": "Dancing Lazer"
    #                 },
    #                 "To": [
    #                     {
    #                         "Email": to_address,
    #                         "Name": receiver_name,
    #                     }
    #                 ],
    #                 "Subject": subject,
    #                 "HTMLPart": html_message
    #             }
    #         ]
    #     }
        
    #     result = mailjet.send.create(data=data)
    #     response = result.json()
    #     response_status_code = response.get("StatusCode")
    #     error_message = response.get("ErrorMessage")

    #     if response_status_code == 200:
    #         return True, None
    #     else:
    #         return False, f"API request failed with status code {response_status_code}; \"{error_message}\""
    
    # except Exception as e:
    #     return False, f"An error occurred: {str(e)}"
