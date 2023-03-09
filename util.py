import streamlit as st
from clips_interface import *
import time
from PIL import Image

def load_file(path):
    with open(path, "r") as f:
        txt = f.read()
    return txt

def file_list(path):
    with open(path, "r") as f:
        lst = f.readlines()
    return lst

def save_file(path, data):
    with open(path, "w") as f:
        f.write(data)

def init_comm():
    save_file("data/commin.txt", '')

def put_commin(comm):
    fil = "data/commin.txt"
    while True:
        lf = load_file(fil)
        if lf == '':
            save_file(fil, comm)
            return
        else:
            time.sleep(1)

def get_commout():
    fil = "data/commout.txt"
    co = file_list(fil)
    if co != '':
        save_file(fil, '')
        return co

def sys_start():
    reset()
    clear()
    load_list(["ch6/comm.clp", "ch6/definitions.clp", "ch6/user_commands.clp", 
                "ch6/kernel.clp", "ch6/data.clp", "ch6/game.clp"])
    reset()
    # watch('all')
    run()

def test_start():
    reset()
    clear()
    load_list(["test/comm.clp", "test/test.clp"])
    reset()
    # watch('all')
    run()

def image_size(w, h, W, H):
    if w >= h:
        typ = 'horiz'
    else:
        typ = 'vert'
    if typ == 'horiz':
        return [W, int(W * h / w)]
    elif typ == 'vert':
        return [int(H * w / h), H]

def create_image(path):
    image = Image.open(path)
    [_, _, w, h] = image.getbbox()
    isiz = image_size(w, h, 700, 500)
    return image.resize(isiz) # W=700, H=500

def parse_buf(buf):
    prn = []
    image = None
    audio = None
    video = None
    for e in buf.split('crlf'):
        if e.startswith('image'):
            image = e.split()[1].replace('"', '')
        elif e.startswith('audio'):
            audio = e.split()[1].replace('"', '')
        elif e.startswith('video'):
            video = e.split()[1].replace('"', '')
        else:
            prn.append(e)
    prn = '\n'.join(prn)
    return [prn, image, audio, video]

def parse_buf_help(buf):
    hh = buf.split('crlf')[1:]
    return '\n'.join(hh)




        