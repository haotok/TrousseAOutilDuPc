import tkinter as tk

class Calculator:
    def __init__(self, master):
        self.master = master
        self.master.title("Calculatrice")
        
        self.result = tk.StringVar()
        
        self.entry = tk.Entry(self.master, textvariable=self.result)
        self.entry.grid(row=0, column=0, columnspan=4, padx=10, pady=10, ipadx=10, ipady=10)
        
        self.create_buttons()
        
    def create_buttons(self):
        buttons = [
            ['7', '8', '9', '+'],
            ['4', '5', '6', '-'],
            ['1', '2', '3', '*'],
            ['0', 'C', '=', '/']
        ]
        
        for row, button_row in enumerate(buttons, 1):
            for col, button_text in enumerate(button_row):
                button = tk.Button(self.master, text=button_text, command=lambda x=button_text: self.click(x))
                button.grid(row=row, column=col, padx=10, pady=10)
    
    def click(self, button_text):
        if button_text == "=":
            try:
                result = eval(self.entry.get())
                self.result.set(result)
            except:
                self.result.set("Erreur")
        elif button_text == "C":
            self.result.set("")
        else:
            self.entry.insert(tk.END, button_text)

if __name__ == "__main__":
    root = tk.Tk()
    calculator = Calculator(root)
    root.mainloop()

