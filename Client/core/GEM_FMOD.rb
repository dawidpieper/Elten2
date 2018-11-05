#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# Audio module
# By Darkleo

module Audio
  extend self
end

class AudioFile
  attr_reader :name
    attr_accessor :channel
  attr_accessor :sound
  attr_reader :closed
  attr_reader :basefreq
  def initialize filename, loopmode = FMod::LOOP_OFF
            if $fmodsounds[$fmodid]>30
      for v in $fmodsounds.keys
        if $fmodsounds[v]==0
          $fmodsounds[v]=nil
FMod::System.dispose(v)
          end
        end
          FMod::System.start
          sleep(0.01)
      end
        @name = filename
    @sound = FMod::Sound.new filename
    @sound.loopMode = loopmode
    @channel = @sound.play true
    @closed = false
    @basefreq = @channel.frequency
      end
  # TODO : use method missing...
  def play
    fail 'File closed' if @closed
    @channel.paused = false
  end
  def playing?
    fail 'File closed' if @closed
    !@channel.paused?
    #@channel start paused
  end
    def pause
    fail 'File closed' if @closed
    @channel.paused = true
  end
  def paused= bool
    fail 'File closed' if @closed
    @channel.paused = bool
  end
  def paused?
    fail 'File closed' if @closed
    @channel.paused?
  end
  def volume
        fail 'File closed' if @closed
    @channel.volume
  end
  def volume= vol
    fail 'File closed' if @closed
    @channel.volume = vol
  end
  def pan
    fail 'File closed' if @closed
    @channel.pan
  end
  def pan= pa
    pa = -0.99 if pa == -1
    pa = 0.99 if pa == 1
    fail 'File closed' if @closed
    @channel.pan = pa
  end
  def pitch=(pi=@channel.frequency)
    @channel.frequency = @basefreq * pi
    end
  def frequency
    fail 'File closed' if @closed
    @channel.frequency
  end
  def frequency= freq
    fail 'File closed' if @closed
    @channel.frequency = freq
  end
  def position unit=FMod::DEFAULT_UNIT
    fail 'File closed' if @closed
    @channel.position unit/1000.0
  end
  def position=(pos, unit=FMod::DEFAULT_UNIT)
    pos*=1000
    fail 'File closed' if @closed
    @channel.position= pos, unit
  end
    def close
      return if @closed
    fail 'File already closed' if @closed
    @channel.stop
    @sound.release
    @closed = true
         end
end




# DLL handle
# By Darkleo
# Thx to for constants and methods names

module FMod
  extend self
  dir = File.dirname(File.dirname(__FILE__))
  DLL_PATH = dir + '/fmodex.dll'

  # FMOD_INITFLAGS flags
  INIT_NORMAL = 0
  # FMOD_RESULT flags
  OK = 0
  ERR_CHANNEL_STOLEN = 11
  ERR_FILE_NOT_FOUND = 23
  ERR_INVALID_HANDLE = 36
  # FMOD_MODE flags
  DEFAULT = 0
  LOOP_OFF = 1
  LOOP_NORMAL = 2
  LOOP_BIDI = 4
  LOOP_BITMASK = 7
  FMOD_2D = 8
  FMOD_3D = 16
  HARDWARE = 32
  SOFTWARE = 64
  CREATESTREAM = 128
  CREATESAMPLE = 256
  OPENUSER = 512
  OPENMEMORY = 1024
  OPENRAW = 2048
  OPENONLY = 4096
  ACCURATETIME = 8192
  MPEGSEARCH = 16384
  NONBLOCKING = 32768
  UNIQUE = 65536
  # The default mode that the script uses
  DEFAULT_SOFTWARWE = LOOP_OFF | FMOD_2D | SOFTWARE
  # FMOD_CHANNELINDEX flags
  CHANNEL_FREE = -1
  CHANNEL_REUSE = -2
  # FMOD_TIMEUNIT_flags
  TIMEUNIT_MS = 1
  TIMEUNIT_PCM = 2
  # The default time unit the script uses
  DEFAULT_UNIT = TIMEUNIT_MS
  # Types supported by FMOD Ex
  FILE_TYPES = ['ogg', 'aac', 'wma', 'mp3', 'wav', 'it', 'xm', 'mod', 's3m', 'mid', 'midi']

  module System
    extend self
    pre = 'FMOD_System_'
    Create       = Win32API.new DLL_PATH, pre + 'Create',       'p',     'l'
    Init         = Win32API.new DLL_PATH, pre + 'Init',         'llll',  'l'
    Close        = Win32API.new DLL_PATH, pre + 'Close',        'l',     'l'
    Release      = Win32API.new DLL_PATH, pre + 'Release',      'l',     'l'
    CreateSound  = Win32API.new DLL_PATH, pre + 'CreateSound',  'lpllp', 'l'
    CreateStream = Win32API.new DLL_PATH, pre + 'CreateStream', 'lpllp', 'l'
    PlaySound    = Win32API.new DLL_PATH, pre + 'PlaySound',    'llllp', 'l'

    def start max_channels=32, flag=INIT_NORMAL, extraDriverData=0
      temp = '\x00'*4
      Create.call temp
            @@id = temp.unpack('i')[0]
$fmodid=@@id
            $fmodsounds={} if $fmodsounds==nil
      $fmodsounds[@@id]=0
      Init.call @@id, 32, INIT_NORMAL, 0
    end
    def dispose(id=@@id)
            return unless id
      Close id
      Release id
      @@id = nil if id==@@id
    end
    def createSound filename, mode=DEFAULT_SOFTWARWE
      $fmodsounds[@@id]+=1
      #temp = '\x00'*4
      #Create.call temp
      #@@id = temp.unpack('i')[0]
      #Init.call @@id, 32, INIT_NORMAL, 0
      filename.gsub("http://") do
              return createStream(filename,mode)
      end
            temp = '\x00'*4
      result = CreateSound.call @@id, filename, mode, 0, temp
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def createStream filename, mode=DEFAULT_SOFTWARWE
      play("signal") if $netsignal==true and filename[0..3].downcase=="http"
      $fmodsounds[@@id]+=1
            temp = '\x00'*4
      result=0
            if (/http(s?):\/\//=~filename) != nil
              result = CreateStream.call @@id, filename, mode, 0, temp
        else    
        result = CreateStream.call @@id, utf8(filename), mode, 0, temp
        end
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def playSound id, paused=false, channel=nil
      temp = channel ? [channel].pack('l') : '\x00'*4
      mode = channel ? CHANNEL_REUSE : CHANNEL_FREE
      paused = paused ? 1 : 0
      PlaySound.call @@id, mode, id, paused, temp
      Channel.new temp.unpack('i')[0]
    end
    def minus
      $fmodsounds[@@id]-=1
      end
  end
  System.start

  class Sound
    pre = 'FMOD_Sound_'
    Release       = Win32API.new DLL_PATH, pre + 'Release',       'l',     'l'
    GetMode       = Win32API.new DLL_PATH, pre + 'GetMode',       'lp',    'l'
    SetMode       = Win32API.new DLL_PATH, pre + 'SetMode',       'll',    'l'
    SetLoopPoints = Win32API.new DLL_PATH, pre + 'SetLoopPoints', 'lllll', 'l'
    GetLength     = Win32API.new DLL_PATH, pre + 'GetLength',     'lpl',   'l'

    attr_reader :id
    attr_reader :channel
    def initialize filename,thr=true
      if $advanced_soundstreaming==0
      @id = System.createSound filename
    else
      @id = System.createStream filename
    end
      if lenght<5 and thr
      Thread.new do
        sleep(10)
        if @channel != nil and @channel.playing? ==false
          release
      end
      end
                end
    end
                def release
System.minus
      Release.call @id
          end
    def play paused=false
      @channel = System.playSound @id, paused
    end
    def mode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def mode=
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def loopMode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0] & LOOP_BITMASK
    end
    def loopMode= newMode
      SetMode.call @id, (mode & ~LOOP_BITMASK | newMode)
    end
    def lenght unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetLength.call @id, temp, unit
      temp.unpack('i')[0]
    end
  end

  class Channel
    pre = 'FMOD_Channel_'
    Stop         = Win32API.new DLL_PATH, pre + 'Stop',         'l',   'l'
    IsPlaying    = Win32API.new DLL_PATH, pre + 'IsPlaying',    'lp',  'l'
    GetPaused    = Win32API.new DLL_PATH, pre + 'GetPaused',    'lp',  'l'
    SetPaused    = Win32API.new DLL_PATH, pre + 'SetPaused',    'll',  'l'
    GetVolume    = Win32API.new DLL_PATH, pre + 'GetVolume',    'lp',  'l'
    SetVolume    = Win32API.new DLL_PATH, pre + 'SetVolume',    'll',  'l'
    GetPan       = Win32API.new DLL_PATH, pre + 'GetPan',       'lp',  'l'
    SetPan       = Win32API.new DLL_PATH, pre + 'SetPan',       'll',  'l'
    GetFrequency = Win32API.new DLL_PATH, pre + 'GetFrequency', 'lp',  'l'
    SetFrequency = Win32API.new DLL_PATH, pre + 'SetFrequency', 'll',  'l'
    GetPosition  = Win32API.new DLL_PATH, pre + 'GetPosition',  'lpl', 'l'
    SetPosition  = Win32API.new DLL_PATH, pre + 'SetPosition',  'lll', 'l'

    attr_reader :id
    def initialize id
      @id = id
    end
    def stop
      Stop.call @id
    end
    def playing?
      temp = '\x00'*4
      IsPlaying.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused?
      temp = '\x00'*4
      GetPaused.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused=bool
      SetPaused.call @id, (bool ? 1 : 0)
    end
    def volume
      temp = '\x00'*4
      GetVolume.call @id, temp
      temp.unpack('f')[0]
    end
    def volume= vol
      SetVolume.call @id, [vol].pack('f').unpack('i')[0]
    end
    def pan
      temp = '\x00'*4
      GetPan.call @id, temp
      temp.unpack('f')[0]
    end
    def pan= pa
      SetPan.call @id, [pa].pack('f').unpack('i')[0]
    end
    def frequency
      temp = '\x00'*4
      GetFrequency.call @id, temp
      temp.unpack('f')[0]
    end
    def frequency= freq
      SetFrequency.call @id, [freq].pack('f').unpack('i')[0]
    end
    def position unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetPosition.call @id, temp, unit
      temp.unpack('i')[0]
    end
    def position= pos, unit=DEFAULT_UNIT
      pos = pos[0] if Array === pos # why [pos, unit] ???
      SetPosition.call @id, pos, unit
    end
  end
end
#Copyright (C) 2014-2018 Dawid Pieper