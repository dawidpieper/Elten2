#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ReadMe
  def main
    text=$dict['_doc_readme']||""
        input_text(_("ReadMe:head"),"READONLY|ACCEPTESCAPE|MULTILINE",text)
    $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2018 Dawid Pieper