#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Voice
  def main
        sel = [_("Voice:opt_changesynth"),_("Voice:opt_changerate"),_("Voice:opt_changevol"),_("Voice:opt_usedefault")]
    @sel = Select.new(sel,true,0,_("Voice:head"))
    loop do
loop_update
     @sel.update
     update
     if $scene != self
       break
     end
     end
   end
   def update
     if escape
              speech_stop
       $scene = Scene_Main.new
     end
     if enter
              case @sel.index
       when 0
       $scene = Scene_Voice_Voice.new(1)
       when 1
         $scene = Scene_Voice_Rate.new
         when 2
           $scene = Scene_Voice_Volume.new
         when 3
                      iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Sapi','Voice',-1.to_s,utf8($configdata + "\\sapi.ini"))
                                $voice = -1
                speech(_("Voice:info_useddefault"))
       end
       end
     end
  end

class Scene_Voice_Voice
  def initialize(settings=0)
    @settings = settings
    end
    def main
      $selectedvoice = false
      nv = Win32API.new("screenreaderapi", "sapiGetNumVoices", '', 'i')
      $numvoice = nv.call() - 1
      $setvoice = Win32API.new("screenreaderapi", "sapiSetVoice", 'i', 'i')
      $setvoice.call(0)
      $voicename = Win32API.new("screenreaderapi", "sapiGetVoiceName", 'i', 'p')
            speech(futf8($voicename.call(0)))
      $curnum = 0
      loop do
loop_update
    update
    if $scene != self
      break
    end
    end
                  end
    def update
      if Input.trigger?(Input::DOWN)
        speech_stop
        if $curnum + 1 <= $numvoice
          $curnum = $curnum + 1
        else
          $curnum = 0
        end
        $setvoice.call($curnum)
        speech(futf8($voicename.call($curnum)))
      end
            if Input.trigger?(Input::UP)
        speech_stop
        if $curnum - 1 >= 0
          $curnum = $curnum - 1
        else
          $curnum = $numvoice
        end
        $setvoice.call($curnum)
        speech(futf8($voicename.call($curnum)))
      end
      if alt
                menu
        end
      if enter or $selectedvoice == true
                iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Sapi','Voice',$curnum.to_s,utf8($configdata + "\\sapi.ini")) if $voice != -3 or @settings != 0
                $voice = $curnum.to_i
                                      mow = "#{_("Voice:info_phr_selectedvoice")}: " + futf8($voicename.call($curnum))
        speech(mow)
speech_wait
if @settings == 0
$scene = Scene_Loading.new
else
  $scene = Scene_Voice.new
  end
end
if escape and @settings != 0
  $scene = Scene_Voice.new
  end
      end
          def menu
play("menu_open")
play("menu_background")
sel = [_("Voice:opt_select")]
sel.push(_("General:str_cancel")) if @settings != 0
@menu = menulr(sel)
loop do
loop_update
@menu.update
if enter
  case @menu.index
  when 0
$selectedvoice = true
break
when 1
  if @settings != 0
    $scene = Scene_Voice.new
    break
    end
end
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
delay(0.25)
return
end
end

class Scene_Voice_Rate
  def main
        sel = []
    for i in 1..100
      sel.push(i.to_s)
    end
    Graphics.update
    @rate = Win32API.new("screenreaderapi","sapiGetRate",'','i').call
    @startrate = @rate
    @sel = Select.new(sel,true,@rate - 1,_("Voice:head_changerate"))
            loop do
loop_update
      @sel.update
      update
      if $scene != self
        break
        end
      end
    end
    def update
if @rate - 1 != @sel.index
  @rate = @sel.index + 1
  Win32API.new("screenreaderapi","sapiSetRate",'i','i').call(@rate)
  end
      @rate = @sel.index + 1
      if escape
                @rate = @startrate
        Win32API.new("screenreaderapi","sapiSetRate",'i','i').call(@rate)
        $scene = Scene_Voice.new
      end
      if enter
                     iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Sapi','Rate',@rate.to_s,utf8($configdata + "\\sapi.ini"))
     speech(_("General:info_saved"))
     speech_wait
     $scene = Scene_Voice.new
        end
      end
    end
    
    class Scene_Voice_Volume
  def main
        sel = []
    for i in 1..100
      sel.push(i.to_s)
    end
        @volume = Win32API.new("screenreaderapi","sapiGetVolume",'','i').call
    @startvolume = @volume
    @sel = Select.new(sel,true,@volume - 1,_("Voice:head_changevol"))
            loop do
loop_update
      @sel.update
      update
      if $scene != self
        break
        end
      end
    end
    def update
if @volume - 1 != @sel.index
  @volume = @sel.index + 1
  Win32API.new("screenreaderapi","sapiSetVolume",'i','i').call(@volume)
  end
      @volume = @sel.index + 1
      if escape
                @volume = @startvolume
        Win32API.new("screenreaderapi","sapiSetVolume",'i','i').call(@volume)
        $scene = Scene_Voice.new
      end
      if enter
                     iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Sapi','Volume',@volume.to_s,utf8($configdata + "\\sapi.ini"))
     speech(_("General:info_saved"))
     speech_wait
     $scene = Scene_Voice.new
        end
      end
  end
#Copyright (C) 2014-2016 Dawid Pieper