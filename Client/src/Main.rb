#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Main
  def main
    NVDA.braille("") if NVDA.check
   if $remauth!=nil
     r=$remauth
     $remauth=nil
     if !r.is_a?(Float)||r<2.32
     txt="W Eltenie 2.28 udostępniony został mechanizm zwany uwierzytelnianiem dwuetapowym.
     Jego celem jest zabezpieczenie kont Eltenowiczów przed utratą nawet w wypadku odgadnięcia lub wykradnięcia hasła. Polega on na potwierdzeniu tożsamości przez wpisanie kodu wysłanego wiadomością SMS na numer telefonu użytkownika za każdym pierwszym logowaniem z nowego urządzenia.
     Czy chcesz skonfigurować uwierzytelnianie dwuetapowe teraz?"
   else
     txt = "Poprzednie wydanie Eltena posiadało błąd uniemożliwiający aktywację uwierzytelniania dwuetapowego.
     Jeśli chcesz, możesz aktywować je teraz.
     Jeśli już wcześniej udało się aktywować uwierzytelnianie dwuetapowe na tym koncie, czynności nie trzeba ponawiać.
     W Eltenie 2.28 udostępniony został mechanizm zwany uwierzytelnianiem dwuetapowym.
     Jego celem jest zabezpieczenie kont Eltenowiczów przed utratą nawet w wypadku odgadnięcia lub wykradnięcia hasła. Polega on na potwierdzeniu tożsamości przez wpisanie kodu wysłanego wiadomością SMS na numer telefonu użytkownika za każdym pierwszym logowaniem z nowego urządzenia.
     Czy chcesz skonfigurować uwierzytelnianie dwuetapowe teraz?"
     end
     confirm(txt) {return $scene=Scene_Authentication.new}
     end
    if $restart==true
      $restart=false
      $scene=Scene_Loading.new
      end
            dialog_close if $dialogopened
    waiting_end if $waitingopened
        $silentstart=false
    if Thread::current != $mainthread
      t = Thread::current
loop_update
                  t.exit
                end
                if $preinitialized!=true
                              $preinitialized = true
            if FileTest.exists?("#{$eltendata}\\playlist.eps")
      $playlist = load_data("#{$eltendata}\\playlist.eps")
      else
      $playlist = [] if $playlist == nil
    end
                $playlistindex = 0 if $playlistindex == nil
                                    whatsnew(true)
      return
      end
            $thr1=Thread.new{thr1} if $thr1.alive? == false
                                    $thr2=Thread.new{thr2} if $thr2.alive? == false
                                    $thr3=Thread.new{thr3} if $thr3.alive? == false
                                                                                                                                      if (($nbeta > $beta) and $isbeta==1) and $denyupdate != true
                            if $portable != 1
      #$scene = Scene_Update_Confirmation.new($scene)
      #return
    else
      alert(p_("Main", "A new beta version of the program is available."))
            end
    end                                                                                                              
              $speech_lasttext = ""
        $ctrldisable = false
        key_update
        speak(p_("Main", "Press the alt key to open the menu."))
        ci = 0
plsinfo = false
    loop do
      ci += 1 if ci < 20
if plsinfo == false and $playlist.size > 0
      if speech_actived == false
  plsinfo = true
selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel = Select.new(selt,true,$playlistindex,p_("Main", "Playlist"),true)
@form=Form.new([@sel,Static.new(p_("Main", "Player")),Button.new(p_("Main", "Shuffle")),Button.new(p_("Main", "Delete the playlist"))],0,true)
@form.fields[2..3]=[nil,nil] if $name=="guest"
    end
  end
  loop_update
      @form.update if @form != nil
                $scene = Scene_Forum.new if $key[115] == true and $key[0x10] == false
        if escape
      quit
    end
if arrow_left and @sel != nil and @form.index == 0
  $playlistbuffer.position -= 5
end
if arrow_right and @sel != nil and @form.index == 0
  $playlistbuffer.position += 5
end
if (space or enter) and @sel != nil and @form != nil
  if @form.index == 0 and enter
    delay(0.5)
  $playlistindex = @sel.index
  $playlistlastindex = -1
elsif @form.index == 2
ind=$playlistindex
  obj=$playlist[ind]
  $playlist.shuffle!
  newind=$playlist.find_index(obj)
  $playlistindex=$playlistlastindex=newind  
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@form.fields[0]=@sel=Select.new(selt,true,$playlistindex,p_("Main", "Playlist"),true)
alert(p_("Main", "Playlist shuffled"))
  elsif @form.index == 3
  $playlist=[]
  $scene=Scene_Main.new
  return
end
  end
if space and @sel != nil and @form != nil and @form.index==0
    if $playlistpaused == true
    $playlistbuffer.play  if $playlistbuffer != nil
    $playlistpaused = false
  else
    $playlistpaused = true
    $playlistbuffer.pause if $playlistbuffer != nil
  end
end
  if $key[0x2e] and @sel != nil
  $playlist.delete_at(@sel.index)
  if @sel.index == $playlistindex
        $playlistlastindex=-1
    end
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@form.fields[0]=@sel=Select.new(selt,true,$playlistindex,p_("Main", "Playlist"),true)
if selt.size > 0
speech(@sel.commandoptions[@sel.index])
else
  $playlistbuffer.pause
  $playlistbuffer = nil
  @sel = nil
  alert(p_("Main", "Playlist removed."))
  end
  end
  if @form != nil and @form.index == 0 and $key[0x10]==true
s=false
    if arrow_up and @sel.index>0
      $playlist[@sel.index],$playlist[@sel.index-1]=$playlist[@sel.index-1],$playlist[@sel.index]
      s=true
      @sel.index-=1
    elsif arrow_down and @sel.index<$playlist.size-1
      $playlist[@sel.index],$playlist[@sel.index+1]=$playlist[@sel.index+1],$playlist[@sel.index]
      s=true
    @sel.index+=1
      end
    if s == true
      play("list_select")
      selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel.commandoptions=selt
speech @sel.commandoptions[@sel.index]
      end
    end
  if @form != nil and @form.index == 1
              if space
        if $playlistbuffer.playing?
        $playlistbuffer.pause
      else
        $playlistbuffer.play
        end
        end
    if $key[0x10] == false
if $keyr[0x27] or $keyr[0x25]
  rp=60 if rp==nil
  rp+=1
  if rp>60
    if $keyr[0x25]
      $playlistbuffer.position-=1
    elsif $keyr[0x27]
      $playlistbuffer.position+=1
      end
    end
else
    rp=60
  end
              if arrow_right
                        pp=$playlistbuffer.position
        $playlistbuffer.position += 5
        if $playlistbuffer.position==pp
              v=$playlistvolume
        $playlistvolume=0
              f=$playlistbuffer.frequency
        $playlistbuffer.frequency*=15
        delay(3.0/15.0)
        $playlistbuffer.frequency=f
        $playlistvolume=v
        end
      end
      if arrow_left
        pp=$playlistbuffer.position
        $playlistbuffer.position -= 5
                $playlistbuffer.position = 0 if $playlistbuffer.position < 5
      end
            if arrow_up
        $playlistvolume += 0.05
$playlistvolume = 0.5 if $playlistvolume == 0.6
      end
      if arrow_down
        $playlistvolume -= 0.05
$playlistvolume = 0.01 if $playlistvolume == 0
end
else
  if arrow_right
        $playlistbuffer.pan += 0.1
        $playlistbuffer.pan = 1 if $playlistbuffer.pan > 1
      end
      if arrow_left
        $playlistbuffer.pan -= 0.1
        $playlistbuffer.pan = -1 if $playlistbuffer.pan < -1
      end
            if arrow_up
        $playlistbuffer.frequency += $playlistbuffer.basefreq.to_f/100.0*2.0
      $playlistbuffer.frequency=$playlistbuffer.basefreq*1.5 if $playlistbuffer.frequency>$playlistbuffer.basefreq*1.5
        end
      if arrow_down
        $playlistbuffer.frequency -= $playlistbuffer.basefreq.to_f/100.0*2.0
      $playlistbuffer.frequency=$playlistbuffer.basefreq/1.5 if $playlistbuffer.frequency<$playlistbuffer.basefreq/1.5
end
end
if $key[0x08] == true
  $playlistvolume=1
  $playlistbuffer.pan=0
  $playlistbuffer.frequency=$playlistbuffer.basefreq
  end
    end
  break if $scene != self
    end
  end
end