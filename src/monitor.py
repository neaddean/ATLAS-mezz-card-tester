#!/usr/bin/python3

# explore Tkinter button as simple toggle
import tkinter as tk  # for Python3 use import tkinter as tk
import serial

def toggle_text():
    """toggle button text between Hi and Goodbye"""
    if button["text"] == "Hi":
        # switch to Goodbye
        button["text"] = "Goodbye"
    else:
        # reset to Hi
        button["text"] = "Hi"

        
root = tk.Tk()
# root.title("Click the Button")
text = tk.Text(root)
text.insert(tk.INSERT, "Bob")
text.pack

# button = tk.Button( text="Hi", width=12, command=toggle_text)
# button.pack(padx=100, pady=10)
root.mainloop()
