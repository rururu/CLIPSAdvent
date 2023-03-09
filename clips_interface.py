import clips

env = clips.Environment()

def eval_clips(command):
    try:
        return env.eval(command)
    except clips.CLIPSError as err:
        return "Err: CLIPS error: {0}".format(err) + ", command: " + command
    except OSError as err:
        return "Err: OS error: {0}".format(err) + ", command: " + command
    except BaseException as err:
        return "Err: BaseException: {0}".format(err) + ", type: {0}".format(type(err)) + ", command: " + command
    else:
        return "Err: Unexpected error!, command: " + command

def load(path):
    return env.load(path)

def load_list(lst):
    print("Loading..")
    for p in lst:
        r = env.eval('(load "'+p+'")')
        print(p+' : '+str(r))

def clear():
    return env.clear()

def reset():
    return env.reset()

def run():
    return env.eval("(run)")

def watch(x):
    return env.eval("(watch "+x+")")

def ass(s):
    env.assert_string(s)

def symbol(s):
    return clips.Symbol(s)

def get_env():
    global env
    return env

