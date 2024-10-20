import re

def user_agent_is_from_mobile(user_agent):
    ua = user_agent.lower()
    if re.search(r'mobile|android|iphone|ipad|iemobile|blackberry|windows phone', ua):
        return True
    return False