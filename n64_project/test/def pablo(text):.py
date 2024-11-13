def pablo(text):
    if len(text) >= 8 and len(text) <= 12 :
        if text.count(" ") == 0:
            if not text.isalnum() :
                return True
    return False

def pablo2(text):
    if (len(text) < 8 or len(text) > 12) :
        return False
    if ( text.count(" ") != 0):
        return False
    has_no_symbols = text.isalnum()
    if (has_no_symbols):
        return False
    return True

def test():
    if (True):
        print("hi")
    elif 1+2 == 3:
        print("HIIII")



print(pablo("This_IS_OKAU"))
print(pablo("noooooooooooo"))
print(pablo("This IS OKAU"))
print(pablo("no12_fhfhfhfhfhfh"))

print(pablo2("This_IS_OKAU"))
print(pablo2("noooooooooooo"))
print(pablo2("This IS OKAU"))
print(pablo2("no12_fhfhfhfhfhfh"))

test()