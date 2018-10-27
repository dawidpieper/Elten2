#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Files
  def initialize(startpath=false)
    @startpath=""
    @startpath=startpath if startpath != false
    @reset=false
    @clp_name=""
    @clp_type=0
        end
  def main
            @tree=FilesTree.new(_("Files:head"),@startpath,false,false,nil,nil,true)
    loop do
      loop_update
      @tree.update
update
        break if $scene != self
      end
    if @played!=nil
       @played.close
       @played=nil
       end
      end
    def update
                
      $scene=Scene_Main.new if escape
     menu if alt
     if $key[0x10] and @played!=nil
       if Input.repeat?(Input::RIGHT)
         @played.position+=5
       elsif Input.repeat?(Input::LEFT)
                  if @played.position<5
         @played.position=0
       else
         @played.position-=5
       end
     elsif Input.repeat?(Input::UP)
       @played.volume+=0.05 if @played.volume<1
       elsif Input.repeat?(Input::DOWN)
       @played.volume-=0.05 if @played.volume>0.05
         end
       end
     if space
       if $key[0x10]==false
       file=@tree.selected(true)
       ext=File.extname(file).downcase
       if @tree.filetype==1
                  if @played!=nil
                           @played.close
       @played=nil
                 end
     if @playedfile != @tree.selected
            begin
                     @played=Bass::Sound.new(@tree.selected(true),1)
                     if @played.cls!=nil
                     @playedfile=@tree.selected
       @played.play
     @playedpause=false
   else
     @played=nil
     end
     rescue Exception
       begin
                  @played=Bass::Sound.new(@tree.selected(true),0)
         @playedfile=@tree.selected
         @played.play
     @playedpause=false
       rescue Exception
         speech(_("Files:error_play"))
         end
       end
        else
     @playedfile=nil
   end
                 end
                                elsif @played!=nil
                 if @playedpause==false
                                  @played.pause
                                  @playedpause=true
                                else @playedpause==true
                                  @played.play
                                  @playedpause=false
                                  end
                 end
     end
                 if $key[115] and @played!=nil
       @played.close
       @played=nil
     end
     if $key[0x2e]
         if simplequestion(s_("Files:alert_delete", {'filename'=>@tree.file})) == 1
    if File.directory?(@tree.selected(false))
      deldir(@tree.selected(false))
speech(_("Files:info_deleted"))
      else
      begin
      File.delete(@tree.selected(false))
    rescue Exception
      speech(_("Files:error_deletefile"))
      end
    end
        @tree.refresh
        play("edit_delete")                
      end
       end
     if $key[0x11] and $key[0x43]
              @clp_type = 1
@clp_file = @tree.selected
@clp_name = @tree.file
speech(_("Files:opt_copied"))
end
if $key[0x11] and $key[0x44]
  if File.directory?(@tree.selected(false))
  o=countsub(@tree.selected(false))
  speech("#{o[1]} plików, #{o[0]} folderów")
else
  ext=File.extname(@tree.selected)
  if @tree.filetype==1
    t=AudioFile.new(@tree.selected)
    d=t.sound.lenght/1000
    t.close
    if d<360000
        h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speech(sprintf("%02d:%02d:%02d",h,m,s))
  end          
  end
  end
  end
if $key[0x11] and $key[0x49]
  size=getsize(@tree.selected(false))
  unit="B"
  if size>1024
    size=size.to_f/1024.0
    unit="KB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="MB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="GB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="TB"
  end
      size=(size*100).round.to_f/100.0
      size=size.to_i if size.to_i==size.to_f
      size=0 if size<0
  speech(size.to_s+unit)
  end
     if $key[0x11] and $key[0x4f]
       run("explorer #{@tree.selected}")
       delay(0.1)
     end
          if $key[0x11] and $key[0x56] and @clp_type>0
                paste
@tree.refresh
end
     if $key[0x11] and $key[0x58]
                     @clp_type = 2
@clp_file = @tree.selected
@clp_name = @tree.file
speech(_("Files:info_cut"))
end
       if enter
       file=@tree.selected(true)
              if File.directory?(file)
dialog_open
         ind=selector([_("Files:opt_opendir"),_("Files:opt_adddirtopls"),_("General:str_cancel")],"",0,2,1)
         dialog_close
         if ind == 0
           @tree.go
         elsif ind == 1
           waiting
           aus=audiosearcher(file)
           waiting_end
                      speech(s_("Files:info_addedtoplscount",{'count'=>aus.size.to_s}))
                      $playlist+=aus
           speech_wait
           end
                  else
if @played!=nil
                           @played.close
       @played=nil
                 end
                    ext=File.extname(file).downcase
if @tree.filetype==1
audiomenu
  elsif @tree.filetype==2
textmenu
elsif @tree.filetype==4
documentmenu            
elsif @tree.filetype==5
  confirm(_("Files:alert_eltenapi")) do
    eval(read(@tree.selected),nil,@tree.file)
    @tree.focus
    end
elsif @tree.filetype==3
            dialog_open
            ind=selector([_("Files:opt_unpack"),_("General:str_cancel")],"",0,1,1)
            dialog_close
            if ind == 0
                            decompress("#{@tree.selected}","#{@tree.path}*")
              speech(_("Files:info_unpacked"))
              @tree.refresh
              speech_wait
              end
                                        end
end
speech(@tree.file)
       end
     end 
     def audiosearcher(path)
       @audiosearcherlastupdate=0 if @audiosearcherlastupdate==nil
       if @audiosearcherlastupdate<Time.now.to_i-5
       loop_update
       @audiosearcherlastupdate=Time.now.to_i
       end
           return if path == nil
  nextsearchs = []
  results = []
  begin      
  files=Dir.entries(path)
rescue Exception
  return []
  end
  files.delete("..")
  files.delete(".")
    exts = [".mp3",".ogg",".wav",".mid"]
        for f in files
          d=path+"\\"+f
          if Win32API.new("shlwapi","PathIsDirectory",'p','i').call(utf8(d))>0
            pth="\0"*2048
            Win32API.new("kernel32","GetShortPathName",'ppi','i').call(utf8(d),pth,pth.size)
            pth.delete!("\0")
            nextsearchs.push(pth)
            else
                 if exts.include?(File.extname(f.downcase))
              results.push(d)
     end
             end
   end
        for i in 0..nextsearchs.size-1
    ns = nextsearchs[i]
    nextsearchs[i] = nil
    results+=audiosearcher(ns)
  end
  return results
end
def paste
  if @clp_type>0
  if File.file?(@clp_file)
  if @clp_type==1
Win32API.new("kernel32","CopyFile",'ppi','i').call(utf8(@clp_file),utf8(@tree.path + @clp_name),0)
elsif @clp_type==2
Win32API.new("kernel32","MoveFile",'pp','i').call(utf8(@clp_file),utf8(@tree.path + @clp_name))
end
else
  copydir(@clp_file,@tree.path + @clp_name)
if @clp_type==2
  deldir(@clp_file)
  end
end
speech(_("Files:info_pasted"))
else
  speech(_("Files:error_clipboardempty"))
end
end
def countsub(dir)
  return [0,0] if dir==nil
  ds=0
  fs=0
  fl=Dir.entries(dir)
  fl.delete(".")
  fl.delete("..")
  for f in fl
    if f!=nil
    if File.file?(dir+"\\"+f)
      fs+=1
    else
      ds+=1
      o=countsub(dir+"\\"+f)
      ds+=o[0]
      fs+=o[1]
    end
    end
  end
  return [ds,fs]
  end
def menu
    if @played!=nil
       @played.close
       @played=nil
     end
     ext=""
if @tree.file!=nil
       afile=@tree.path+@tree.file
  file=@tree.selected(true)
  ext=File.extname(file).downcase
  end
  play("menu_open")
  play("menu_background")
  sel = [[_("Files:opt_file"),_("Files:opt_openassociated"),_("Files:opt_send"),_("Files:opt_pack"),_("Files:opt_rename"),_("General:str_delete")],[_("Files:opt_clipboard"),_("Files:opt_copy"),_("Files:opt_cut"),_("Files:opt_paste")],[_("Files:opt_create"),_("Files:opt_newdir"),_("Files:opt_newdoc"),_("Files:opt_newrec")],_("Files:opt_erasepls")]
    sel[0][3]=_("Files:opt_unpack") if ext==".rar" or ext==".zip" or ext==".7z"
      sel.push(_("Files:opt_audio")) if @tree.filetype==1
  sel.push(_("Files:opt_text")) if @tree.filetype==2
  sel.push("Dokument") if @tree.filetype==4
  if File.directory?(@tree.selected(true))
    sel[0][0]=_("Files:opt_dir")
sel[0][2]=_("Files:opt_adddirtopls")
end
@menu=Tree.new(sel,0,"",false,true)
  loop do
    loop_update
        @menu.update
    if alt or escape
      break
    end
    if Input.trigger?(Input::DOWN) and @menu.index==15
      d=-1
      if ext==".mp3" or ext==".wav" or ext==".ogg" or ext==".flac" or ext==".mid" or ext==".wma"
      d=audiomenu(true)
      elsif ext == ".txt"
      d=textmenu(true)
      elsif ext == ".doc" or ext==".docx" or ext==".epu" or ext==".epub" or ext==".html" or ext==".mobi" or ext==".pdf"
d=documentmenu(true)
      end
      if d!=-1
        break
      else
        @menu.focus
        end
      end
    if @menu.opfocused
      loop_update
      nb=false
      case @menu.index
when 1
      run("explorer \"#{afile}\"")
      when 2
        if File.directory?(@tree.selected(true))
          waiting
          aus=audiosearcher(file)
          waiting_end
           speech(s_("Files:info_addedtoplscount",{'count'=>aus.size.to_s}))
           $playlist+=aus
           speech_wait
           else
        if $name!="guest"
             if sendfile(afile).is_a?(String)
          speech(_("Files:info_sent"))
        else
          speech(_("General:error"))
        end
      else
        speech(_("General:error_guest"))
        end
        speech_wait
        end
        when 3
      if ext != ".rar" and ext != ".zip" and ext != ".7z"
          f=selector(["zip","rar","7zip"],_("Files:head_archiveformat"),0,-1,1)
      if f>=0
        dest=file
        case f
        when 0
          dest+=".zip"
          when 1
            dest+=".rar"
            when 2
              dest+=".7z"
        end
        compress(file,dest)
        speech(_("Files:info_packed"))
        speech_wait
      end
    else
      decompress(@tree.selected,@tree.path+"*")
              speech(_("Files:info_unpacked"))
                            speech_wait
      end
when 4
    name=""
    while name==""
    name=input_text(_("Files:type_newname"),"ACCEPTESCAPE",@tree.file)
    end
    if name != "\004ESCAPE\004"
    Win32API.new("kernel32","MoveFile",'pp','i').call(utf8(file),utf8(@tree.path+name))
    speech(_("Files:info_renamed"))
    speech_wait
  end
when 5
  if simplequestion(s_("Files:alert_delete", {'filename'=>@tree.file})) == 1
    if File.directory?(afile)
      deldir(afile)
    else
      File.delete(afile)
    end
    speech(_("Files:info_deleted"))
    speech_wait
  end
          when 7
@clp_type = 1
@clp_file = afile
@clp_name = @tree.file
speech(_("Files:info_copied"))
when 8
              @clp_type = 2
@clp_file = afile
@clp_name = @tree.file
speech(_("Files:info_cut"))
speech_wait
when 9
  paste
  @tree.refresh
speech_wait  
when 11
  name=""
while name==""
      name=input_text(_("Files:type_dirname"),"ACCEPTESCAPE","")
      end
    if name != "\004ESCAPE\004"
      Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8(@tree.path+name),nil)
      speech(_("Files:info_dircreated"))
      speech_wait
    end
          when 12
  pr=".txt"
  name=""
    while name == ""
    name=input_text(_("Files:type_filename"),"ACCEPTESCAPE",pr)
  end
  if name!="\004ESCAPE\004"            
  writefile(@tree.path+name,"")
        speech(_("Files:info_filecreated"))
      speech_wait
  end
      when 13
        pr=".wav"
        name=""
    while name == ""
    name=input_text(_("Files:type_filename"),"ACCEPTESCAPE",pr)
    end
    if name != "\004ESCAPE\004"
            form=Form.new([Button.new(_("Files:btn_record")),Button.new(_("General:str_cancel"))])
     rec=0
     loop do
       loop_update
       form.update
       if ((space or enter) and form.index == 0)
         if rec == 0
           rec = 1
           play("recording_start")
           recording_start(@tree.path+name)
         form.fields[0]=Button.new(_("General:str_save"))
           elsif rec == 1
           recording_stop
           play("recording_stop")
           speech(_("General:info_saved"))
           break
                      end
         end
       if escape or ((enter or space) and form.index==1)
         recording_stop if rec==1
         break
         end
       end
            speech(_("Files:info_filecreated"))
      speech_wait
        end
        when 14
      $playlist=[]
      $playlistindex = 0
      speech(_("Files:info_plserased"))
      speech_wait
      when 15
        d=-1
      if ext==".mp3" or ext==".wav" or ext==".ogg" or ext==".flac" or ext==".mid" or ext==".wma"
      d=audiomenu(true)
      elsif ext == ".txt"
      d=textmenu(true)
      end
      if d==-1
                      @menu.focus
                      nb=true
        end
      end
    @tree.refresh
    break if nb==false
    end
  end
  play("menu_close")
Audio.bgs_stop
end
def audiomenu(submenu=false)
  dialog_open if submenu==false
  ck=nil
  ck=Input::UP if submenu
  sl=[_("Files:opt_play"),_("Files:opt_addtopls"),_("Files:opt_avatar"),_("Files:opt_convert")]
  sl.push(_("General:str_cancel")) if submenu==false
    ind = selector(sl,"",0,-1,1,true,ck)
dialog_close if submenu==false
Audio.bgs_stop if submenu and ind!=-1
case ind
when 0
  player(@tree.selected(true),"Odtwarzanie: #{File.basename(@tree.path+@tree.file)}",true)
  when 1
    $playlist.push(@tree.path+@tree.file)
    when 2
      avatar_set(@tree.path+@tree.file)
      speech_wait
      when 3
formats=[".mp3",".ogg",".wav",".flac",".wma",".aac",".m4a",".opus"]
f=selector(formats,_("Files:head_convertto"),0,-1)
if f!=-1
format=formats[f]
extra=""
if format!=".wav" and format!=".flac"
  bts=[48,64,96,128,160,192,224,256,320]
  btrs=[]
  for b in bts
    btrs.push(b.to_s+"KBPS")
  end
  bt=selector(btrs,_("Files:head_soundquality"),5)
  extra="-b:a #{bts[bt]}K "
    end
speech(_("Files:wait_converting"))
waiting
c="bin/ffmpeg -y -i \"#{@tree.selected}\" #{extra}\"#{@tree.selected.gsub(File.extname(@tree.selected),format)}\""
executeprocess(c,true)
speech_wait
waiting_end
speech(_("Files:info_converted"))
speech_wait
@tree.refresh
end
end
return ind
end
def textmenu(submenu=false)
  file=@tree.selected
      dialog_open if submenu==false
      sl=[_("Files:opt_edit"),_("Files:opt_readtofile")]
      sl.push(_("General:str_cancel")) if submenu==false
   ck=nil
   ck=Input::UP if submenu
          ind=selector(sl,"",0,-1,1,true,ck)
    dialog_close if submenu==false
    Audio.bgs_stop if submenu and ind != -1
    case ind
    when 0
    form=Form.new([Edit.new(@tree.file,"MULTILINE",read(file,false,true)),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
    loop do
      loop_update
      form.update
      break if escape or ((space or enter) and form.index == 2)
      if ((space or enter) and form.index == 1) or (enter and $key[0x11])
        writefile(@tree.path+@tree.file,form.fields[0].text_str.gsub("\004LINE\004","\r\n"))
        speech(_("General:info_saved"))
        break
              end
            end
            when 1
              speechtofile(@tree.selected(true),"")
            end
            return -1
            end
          def documentmenu(submenu=false)
      dialog_open if submenu==false
      sl=[_("Files:opt_read"),_("Files:opt_readtofile")]
      sl.push(_("General:str_cancel")) if submenu==false
   ck=nil
   ck=Input::UP if submenu
          ind=selector(sl,"",0,-1,1,true,ck)
    dialog_close if submenu==false
    Audio.bgs_stop if submenu and ind != -1
    text=""
    fid=0
    fid="tx"+rand(36**8).to_s(36)+""
    if ind<2 and ind>-1
      speech(_("Files:wait_processing"))
      waiting
      executeprocess("bin\\blb2txt.exe -f \"#{@tree.selected}\" -v \"temp\\\" -p \"#{fid}\" -e \"utf8\"",true)
            text=read("temp\\"+fid+".txt")
            waiting_end
      end
    case ind
    when 0
          File.delete("temp\\"+fid+".txt")
          form=Form.new([Edit.new(@tree.file,"MULTILINE|READONLY",text),Button.new(_("General:str_quit"))])
    loop do
      loop_update
      form.update
      break if escape or ((space or enter) and form.index == 1)
                  end
            when 1
              speechtofile("temp\\#{fid}.txt","",File.basename(@tree.file).gsub(File.extname(@tree.file),""))
                          end
            File.delete("temp\\"+fid+".txt") if FileTest.exists?("temp\\"+fid+".txt")
                          return -1
            end
          

end
#Copyright (C) 2014-2016 Dawid Pieper