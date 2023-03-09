import streamlit as st
from util import *
from clips_interface import *
import time
from streamlit_option_menu import option_menu

st.set_page_config(
	layout="wide"
)
st.markdown(
    """
    <style>
    .main {
    background-color: #200030;
    }
    </style>
    """,
    unsafe_allow_html=True
)

# Initial session state
if "text_area" not in st.session_state:
	st.session_state["text_area"] = 'Hello!'
if "image" not in st.session_state:
	st.session_state["image"] = "img/AinRBP1.jpg"
if "audio" not in st.session_state:
	st.session_state["audio"] = None
if "video" not in st.session_state:
	st.session_state["video"] = None
if "user_input" not in st.session_state:
	st.session_state["user_input"] = None
if "started" not in st.session_state or st.session_state["started"] is None:
	#test_start()
	sys_start()
	init_comm()
	st.session_state["started"] = True
if "error" not in st.session_state:
	st.session_state["error"] = None
if "help" not in st.session_state:
	st.session_state["help"] = None


# Variables
trig = 0

# ---------------------------------- Web Page --------------------------------------

st.title(':japanese_ogre::japanese_ogre::japanese_ogre: :orange[Adventures in RULE-BASED PROGRAMMING] :mushroom::skull::skull::skull:')

col_dlg, col_hlp, col_med = st.columns([2, 1, 4])

with col_dlg:

	usinp = st.text_input(':green[User]', key='ti'+str(trig))
	if len(usinp) == 0:
		st.session_state.user_input = None
	elif usinp != st.session_state.user_input:
		st.session_state.user_input = usinp
		put_commin(usinp)
		res = eval_clips('(exec-user-command)')
		# print("RES "+str(res))
		if res and res.startswith('Err:'):
			st.session_state.error = res
	if st.session_state.error is None:
		buf = eval_clips('(get-buf)')
		# print("BUF: "+str(buf))
		if buf.startswith('restart'):
			st.session_state.started = None
			st.session_state.image = None
			st.session_state.audio = None
			st.session_state.video = "video/Clock.mp4"
		elif buf.startswith('Err:'):
			st.session_state.error = buf
		elif buf.startswith('%HELP%'):
			st.session_state.help = parse_buf_help(buf)
		elif buf != '':
			[prn, image, audio, video] = parse_buf(buf)
			st.session_state.image = image
			st.session_state.audio = audio
			st.session_state.video = video
			st.session_state.text_area = prn+"\n"+st.session_state.text_area
	st.text_area(':blue[Expert System]', st.session_state.text_area, height=380, key='ta'+str(trig))
	time.sleep(1)
	if trig == 0:
		trig = 1
	else:
		trig = 0

with col_hlp:

	if st.session_state.help is not None:
		st.text_area(':green[Help]', st.session_state.help, height=470)

with col_med:

	if st.session_state.image is not None:
		st.image(create_image(st.session_state.image))
	if st.session_state.video is not None:
		st.video(st.session_state.video)
	if st.session_state.audio is not None:
		st.audio(st.session_state.audio)

if st.session_state.error != None:
	st.text_area(":red[CLIPS]", st.session_state.error)
	me_ops = ['', 'facts', 'agenda', 'clear', 'reset', 'watch', 'unwatch all', 'restart', 'clear error']
	sel_menu = option_menu(menu_title=None, options=me_ops, orientation="horizontal")
	if sel_menu == 'clear error':
		st.session_state.error = None
		st.experimental_rerun()
	elif sel_menu == 'facts':
		eval_clips('(facts)')
	elif sel_menu == 'agenda':
		eval_clips('(agenda *)')
	elif sel_menu == 'clear':
		eval_clips('(clear)')
	elif sel_menu == 'reset':
		eval_clips('(reset)')
	elif sel_menu == 'restart':
		st.session_state.started = None
		st.session_state.error = None
		st.experimental_rerun()
	elif sel_menu == 'unwatch all':
		eval_clips('(unwatch all)')
	elif sel_menu == 'watch':
		w_ops = ['facts', 'rules', 'activations', 'globals', 'all']
		w_menu = option_menu(menu_title=None, options=w_ops, orientation='horizontal')
		if w_menu == 'facts':
			eval_clips('(watch facts)')
		elif w_menu == 'rules':
			eval_clips('(watch rules)')
		elif w_menu == 'activations':
			eval_clips('(watch activations)')
		elif w_menu == 'globals':
			eval_clips('(watch globals)')
		elif w_menu == 'all':
			eval_clips('(watch all)')

		




