#===============================================================================
#
#===============================================================================
class SpriteWindowCursorRect < Rect
  def initialize(window)
    @window=window
    @x=0
    @y=0
    @width=0
    @height=0
  end

  attr_reader :x,:y,:width,:height

  def empty
    needupdate=@x!=0 || @y!=0 || @width!=0 || @height!=0
    if needupdate
      @x=0
      @y=0
      @width=0
      @height=0
      @window.width=@window.width
    end
  end

  def isEmpty?
    return @x==0 && @y==0 && @width==0 && @height==0
  end

  def set(x,y,width,height)
    needupdate=@x!=x || @y!=y || @width!=width || @height!=height
    if needupdate
      @x=x
      @y=y
      @width=width
      @height=height
      @window.width=@window.width
    end
  end

  def height=(value)
    @height=value; @window.width=@window.width
  end

  def width=(value)
    @width=value; @window.width=@window.width
  end

  def x=(value)
    @x=value; @window.width=@window.width
  end

  def y=(value)
    @y=value; @window.width=@window.width
  end
end



#===============================================================================
# SpriteWindow is a class based on Window which emulates Window's functionality.
# This class is necessary in order to change the viewport of windows (with
# viewport=) and to make windows fade in and out (with tone=).
#===============================================================================
class SpriteWindow < Window
  attr_reader :tone
  attr_reader :color
  attr_reader :viewport
  attr_reader :contents
  attr_reader :ox
  attr_reader :oy
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :zoom_x
  attr_reader :zoom_y
  attr_reader :offset_x
  attr_reader :offset_y
  attr_reader :width
  attr_reader :active
  attr_reader :pause
  attr_reader :height
  attr_reader :opacity
  attr_reader :back_opacity
  attr_reader :contents_opacity
  attr_reader :visible
  attr_reader :cursor_rect
  attr_reader :contents_blend_type
  attr_reader :blend_type
  attr_reader :openness

  def windowskin
    @_windowskin
  end

  # Flags used to preserve compatibility
  # with RGSS/RGSS2's version of Window
  module CompatBits
    CorrectZ         = 1
    ExpandBack       = 2
    ShowScrollArrows = 4
    StretchSides     = 8
    ShowPause        = 16
    ShowCursor       = 32
  end

  attr_reader :compat

  def compat=(value)
    @compat=value
    privRefresh(true)
  end

  def initialize(viewport=nil)
    @sprites={}
    @spritekeys=[
       "back",
       "corner0","side0","scroll0",
       "corner1","side1","scroll1",
       "corner2","side2","scroll2",
       "corner3","side3","scroll3",
       "cursor","contents","pause"
    ]
    @viewport=viewport
    @sidebitmaps=[nil,nil,nil,nil]
    @cursorbitmap=nil
    @bgbitmap=nil
    for i in @spritekeys
      @sprites[i]=Sprite.new(@viewport)
    end
    @disposed=false
    @tone=Tone.new(0,0,0)
    @color=Color.new(0,0,0,0)
    @blankcontents=Bitmap.new(1,1) # RGSS2 requires this
    @contents=@blankcontents
    @_windowskin=nil
    @rpgvx=false
    @compat=CompatBits::ExpandBack|CompatBits::StretchSides
    @x=0
    @y=0
    @width=0
    @height=0
    @offset_x=0
    @offset_y=0
    @zoom_x=1.0
    @zoom_y=1.0
    @ox=0
    @oy=0
    @z=0
    @stretch=true
    @visible=true
    @active=true
    @openness=255
    @opacity=255
    @back_opacity=255
    @blend_type=0
    @contents_blend_type=0
    @contents_opacity=255
    @cursor_rect=SpriteWindowCursorRect.new(self)
    @cursorblink=0
    @cursoropacity=255
    @pause=false
    @pauseframe=0
    @flash=0
    @pauseopacity=0
    @skinformat=0
    @skinrect=Rect.new(0,0,0,0)
    @trim=[16,16,16,16]
    privRefresh(true)
  end

  def dispose
    if !self.disposed?
      for i in @sprites
        i[1].dispose if i[1]
        @sprites[i[0]]=nil
      end
      for i in 0...@sidebitmaps.length
        @sidebitmaps[i].dispose if @sidebitmaps[i]
        @sidebitmaps[i]=nil
      end
      @blankcontents.dispose
      @cursorbitmap.dispose if @cursorbitmap
      @backbitmap.dispose if @backbitmap
      @sprites.clear
      @sidebitmaps.clear
      @_windowskin=nil
      @disposed=true
    end
  end

  def stretch=(value)
    @stretch=value
    privRefresh(true)
  end

  def visible=(value)
    @visible=value
    privRefresh
  end

  def viewport=(value)
    @viewport=value
    for i in @spritekeys
      @sprites[i].dispose if @sprites[i]
    end
    for i in @spritekeys
      if @sprites[i].is_a?(Sprite)
        @sprites[i]=Sprite.new(@viewport)
      else
        @sprites[i]=nil
      end
    end
    privRefresh(true)
  end

  def z=(value)
    @z=value
    privRefresh
  end

  def disposed?
    return @disposed
  end

  def contents=(value)
    if @contents!=value
      @contents=value
      privRefresh if @visible
    end
  end

  def ox=(value)
    if @ox!=value
      @ox=value
      privRefresh if @visible
    end
  end

  def oy=(value)
    if @oy!=value
      @oy=value
      privRefresh if @visible
    end
  end

  def active=(value)
     @active=value
     privRefresh(true)
  end

  def cursor_rect=(value)
    if !value
      @cursor_rect.empty
    else
      @cursor_rect.set(value.x,value.y,value.width,value.height)
    end
  end

  def openness=(value)
    @openness=value
    @openness=0 if @openness<0
    @openness=255 if @openness>255
    privRefresh
  end

  def width=(value)
    @width=value
    privRefresh(true)
  end

  def height=(value)
    @height=value
    privRefresh(true)
  end

  def pause=(value)
    @pause=value
    @pauseopacity=0 if !value
    privRefresh if @visible
  end

  def x=(value)
    @x=value
    privRefresh if @visible
  end

  def y=(value)
    @y=value
    privRefresh if @visible
  end

  def zoom_x=(value)
    @zoom_x=value
    privRefresh if @visible
  end

  def zoom_y=(value)
    @zoom_y=value
    privRefresh if @visible
  end

  def offset_x=(value)
    @x=value
    privRefresh if @visible
  end

  def offset_y=(value)
    @y=value
    privRefresh if @visible
  end

  def opacity=(value)
    @opacity=value
    @opacity=0 if @opacity<0
    @opacity=255 if @opacity>255
    privRefresh if @visible
  end

  def back_opacity=(value)
    @back_opacity=value
    @back_opacity=0 if @back_opacity<0
    @back_opacity=255 if @back_opacity>255
    privRefresh if @visible
  end

  def contents_opacity=(value)
    @contents_opacity=value
    @contents_opacity=0 if @contents_opacity<0
    @contents_opacity=255 if @contents_opacity>255
    privRefresh if @visible
  end

  def tone=(value)
    @tone=value
    privRefresh if @visible
  end

  def color=(value)
    @color=value
    privRefresh if @visible
  end

  def blend_type=(value)
    @blend_type=value
    privRefresh if @visible
  end

  def flash(color,duration)
    return if disposed?
    @flash=duration+1
    for i in @sprites
      i[1].flash(color,duration)
    end
  end

  def update
    return if disposed?
    mustchange=false
    if @active
      if @cursorblink==0
        @cursoropacity-=8
        @cursorblink=1 if @cursoropacity<=128
      else
        @cursoropacity+=8
        @cursorblink=0 if @cursoropacity>=255
      end
      privRefreshCursor
    else
      @cursoropacity=128
      privRefreshCursor
    end
    if @pause
      oldpauseframe=@pauseframe
      oldpauseopacity=@pauseopacity
      @pauseframe=(Graphics.frame_count / 8) % 4
      @pauseopacity=[@pauseopacity+64,255].min
      mustchange=@pauseframe!=oldpauseframe || @pauseopacity!=oldpauseopacity
    end
    privRefresh if mustchange
    if @flash>0
      for i in @sprites.values
        i.update
      end
      @flash-=1
    end
  end

  #############
  attr_reader :skinformat
  attr_reader :skinrect

  def loadSkinFile(_file)
    if (self.windowskin.width==80 || self.windowskin.width==96) &&
       self.windowskin.height==48
      # Body = X, Y, width, height of body rectangle within windowskin
      @skinrect.set(32,16,16,16)
      # Trim = X, Y, width, height of trim rectangle within windowskin
      @trim=[32,16,16,16]
    elsif self.windowskin.width==80 && self.windowskin.height==80
      @skinrect.set(32,32,16,16)
      @trim=[32,16,16,48]
    end
  end

  def windowskin=(value)
    oldSkinWidth=(@_windowskin && !@_windowskin.disposed?) ? @_windowskin.width : -1
    oldSkinHeight=(@_windowskin && !@_windowskin.disposed?) ? @_windowskin.height : -1
    @_windowskin=value
    if @skinformat==1
      @rpgvx=false
      if @_windowskin && !@_windowskin.disposed?
        if @_windowskin.width!=oldSkinWidth || @_windowskin.height!=oldSkinHeight
          # Update skinrect and trim if windowskin's dimensions have changed
          @skinrect.set((@_windowskin.width-16)/2,(@_windowskin.height-16)/2,16,16)
          @trim=[@skinrect.x,@skinrect.y,@skinrect.x,@skinrect.y]
        end
      else
        @skinrect.set(16,16,16,16)
        @trim=[16,16,16,16]
      end
    else
      if value && value.is_a?(Bitmap) && !value.disposed? && value.width==128
        @rpgvx=true
      else
        @rpgvx=false
      end
      @trim=[16,16,16,16]
    end
    privRefresh(true)
  end

  def skinrect=(value)
    @skinrect=value
    privRefresh
  end

  def skinformat=(value)
    if @skinformat!=value
      @skinformat=value
      privRefresh(true)
    end
  end

  def borderX
    return 32 if !@trim || skinformat==0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[0]+(@_windowskin.width-@trim[2]-@trim[0])
    end
    return 32
  end

  def borderY
    return 32 if !@trim || skinformat==0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[1]+(@_windowskin.height-@trim[3]-@trim[1])
    end
    return 32
  end

  def leftEdge; self.startX; end
  def topEdge; self.startY; end
  def rightEdge; self.borderX-self.leftEdge; end
  def bottomEdge; self.borderY-self.topEdge; end

  def startX
    return !@trim || skinformat==0  ? 16 : @trim[0]
  end

  def startY
    return !@trim || skinformat==0  ? 16 : @trim[1]
  end

  def endX
    return !@trim || skinformat==0  ? 16 : @trim[2]
  end

  def endY
    return !@trim || skinformat==0  ? 16 : @trim[3]
  end

  def startX=(value)
    @trim[0]=value
    privRefresh
  end

  def startY=(value)
    @trim[1]=value
    privRefresh
  end

  def endX=(value)
    @trim[2]=value
    privRefresh
  end

  def endY=(value)
    @trim[3]=value
    privRefresh
  end

  #############
  private

  def ensureBitmap(bitmap,dwidth,dheight)
    if !bitmap||bitmap.disposed?||bitmap.width<dwidth||bitmap.height<dheight
      bitmap.dispose if bitmap
      bitmap=Bitmap.new([1,dwidth].max,[1,dheight].max)
    end
    return bitmap
  end

  def tileBitmap(dstbitmap,dstrect,srcbitmap,srcrect)
    return if !srcbitmap || srcbitmap.disposed?
    left=dstrect.x
    top=dstrect.y
    y=0;loop do break unless y<dstrect.height
      x=0;loop do break unless x<dstrect.width
        dstbitmap.blt(x+left,y+top,srcbitmap,srcrect)
        x+=srcrect.width
      end
      y+=srcrect.height
    end
  end

  def privRefreshCursor
    contopac=self.contents_opacity
    cursoropac=@cursoropacity*contopac/255
    @sprites["cursor"].opacity=cursoropac
  end

  def privRefresh(changeBitmap=false)
    return if !self || self.disposed?
    backopac=self.back_opacity*self.opacity/255
    contopac=self.contents_opacity
    cursoropac=@cursoropacity*contopac/255
    haveskin=@_windowskin && !@_windowskin.disposed?
    for i in 0...4
      @sprites["corner#{i}"].bitmap=@_windowskin
      @sprites["scroll#{i}"].bitmap=@_windowskin
    end
    @sprites["pause"].bitmap=@_windowskin
    @sprites["contents"].bitmap=@contents
    if haveskin
      for i in 0...4
        @sprites["corner#{i}"].opacity=@opacity
        @sprites["corner#{i}"].tone=@tone
        @sprites["corner#{i}"].color=@color
        @sprites["corner#{i}"].visible=@visible
        @sprites["corner#{i}"].blend_type=@blend_type
        @sprites["side#{i}"].opacity=@opacity
        @sprites["side#{i}"].tone=@tone
        @sprites["side#{i}"].color=@color
        @sprites["side#{i}"].blend_type=@blend_type
        @sprites["side#{i}"].visible=@visible
        @sprites["scroll#{i}"].opacity=@opacity
        @sprites["scroll#{i}"].tone=@tone
        @sprites["scroll#{i}"].color=@color
        @sprites["scroll#{i}"].visible=@visible
        @sprites["scroll#{i}"].blend_type=@blend_type
      end
      for i in ["back","cursor","pause","contents"]
        @sprites[i].color=@color
        @sprites[i].tone=@tone
        @sprites[i].blend_type=@blend_type
      end
      @sprites["contents"].blend_type=@contents_blend_type
      @sprites["back"].opacity=backopac
      @sprites["contents"].opacity=contopac
      @sprites["cursor"].opacity=cursoropac
      @sprites["pause"].opacity=@pauseopacity
      supported=(@skinformat==0)
      hascontents=(@contents && !@contents.disposed?)
      @sprites["back"].visible=@visible
      @sprites["contents"].visible=@visible && @openness==255
      @sprites["pause"].visible=supported && @visible && @pause &&
         (@combat & CompatBits::ShowPause)
      @sprites["cursor"].visible=supported && @visible && @openness==255 &&
         (@combat & CompatBits::ShowCursor)
      @sprites["scroll0"].visible = false
      @sprites["scroll1"].visible = false
      @sprites["scroll2"].visible = false
      @sprites["scroll3"].visible = false
    else
      for i in 0...4
        @sprites["corner#{i}"].visible=false
        @sprites["side#{i}"].visible=false
        @sprites["scroll#{i}"].visible=false
      end
      @sprites["contents"].visible=@visible && @openness==255
      @sprites["contents"].color=@color
      @sprites["contents"].tone=@tone
      @sprites["contents"].blend_type=@contents_blend_type
      @sprites["contents"].opacity=contopac
      @sprites["back"].visible=false
      @sprites["pause"].visible=false
      @sprites["cursor"].visible=false
    end
    for i in @spritekeys
      @sprites[i].z=@z
    end
    if (@compat & CompatBits::CorrectZ)>0 && @skinformat==0 && !@rpgvx
      # Compatibility Mode: Cursor, pause, and contents have higher Z
      @sprites["cursor"].z=@z+1
      @sprites["contents"].z=@z+2
      @sprites["pause"].z=@z+2
    end
    if @skinformat==0
      startX=16
      startY=16
      endX=16
      endY=16
      trimStartX=16
      trimStartY=16
      trimWidth=32
      trimHeight=32
      if @rpgvx
        trimX=64
        trimY=0
        backRect=Rect.new(0,0,64,64)
        blindsRect=Rect.new(0,64,64,64)
      else
        trimX=128
        trimY=0
        backRect=Rect.new(0,0,128,128)
        blindsRect=nil
      end
      if @_windowskin && !@_windowskin.disposed?
        @sprites["corner0"].src_rect.set(trimX,trimY+0,16,16);
        @sprites["corner1"].src_rect.set(trimX+48,trimY+0,16,16);
        @sprites["corner2"].src_rect.set(trimX,trimY+48,16,16);
        @sprites["corner3"].src_rect.set(trimX+48,trimY+48,16,16);
        @sprites["scroll0"].src_rect.set(trimX+24, trimY+16, 16, 8) # up
        @sprites["scroll3"].src_rect.set(trimX+24, trimY+40, 16, 8) # down
        @sprites["scroll1"].src_rect.set(trimX+16, trimY+24, 8, 16) # left
        @sprites["scroll2"].src_rect.set(trimX+40, trimY+24, 8, 16) # right
        cursorX=trimX
        cursorY=trimY+64
        sideRects=[
           Rect.new(trimX+16,trimY+0,32,16),
           Rect.new(trimX,trimY+16,16,32),
           Rect.new(trimX+48,trimY+16,16,32),
           Rect.new(trimX+16,trimY+48,32,16)
        ]
        pauseRects=[
           trimX+32,trimY+64,
           trimX+48,trimY+64,
           trimX+32,trimY+80,
           trimX+48,trimY+80,
        ]
        pauseWidth=16
        pauseHeight=16
        @sprites["pause"].src_rect.set(
           pauseRects[@pauseframe*2],
           pauseRects[@pauseframe*2+1],
           pauseWidth,pauseHeight
        )
      end
    else
      trimStartX=@trim[0]
      trimStartY=@trim[1]
      trimWidth=@trim[0]+(@skinrect.width-@trim[2]+@trim[0])
      trimHeight=@trim[1]+(@skinrect.height-@trim[3]+@trim[1])
      if @_windowskin && !@_windowskin.disposed?
        # width of left end of window
        startX=@skinrect.x
        # width of top end of window
        startY=@skinrect.y
        cx=@skinrect.x+@skinrect.width # right side of BODY rect
        cy=@skinrect.y+@skinrect.height # bottom side of BODY rect
        # width of right end of window
        endX=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.x : @_windowskin.width-cx
        # height of bottom end of window
        endY=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.y : @_windowskin.height-cy
        @sprites["corner0"].src_rect.set(0,0,startX,startY);
        @sprites["corner1"].src_rect.set(cx,0,endX,startY);
        @sprites["corner2"].src_rect.set(0,cy,startX,endY);
        @sprites["corner3"].src_rect.set(cx,cy,endX,endY);
        backRect=Rect.new(@skinrect.x,@skinrect.y,
           @skinrect.width,@skinrect.height);
        blindsRect=nil
        sideRects=[
           Rect.new(startX,0,@skinrect.width,startY),  # side0 (top)
           Rect.new(0,startY,startX,@skinrect.height), # side1 (left)
           Rect.new(cx,startY,endX,@skinrect.height),  # side2 (right)
           Rect.new(startX,cy,@skinrect.width,endY)    # side3 (bottom)
        ]
      end
    end
    if @width>trimWidth && @height>trimHeight
      @sprites["contents"].src_rect.set(@ox,@oy,@width-trimWidth,@height-trimHeight)
    else
      @sprites["contents"].src_rect.set(0,0,0,0)
    end
    @sprites["contents"].x=@x+trimStartX
    @sprites["contents"].y=@y+trimStartY
    if (@compat & CompatBits::ShowScrollArrows)>0 && @skinformat==0
      # Compatibility mode: Make scroll arrows visible
      if @skinformat==0 && @_windowskin && !@_windowskin.disposed? &&
         @contents && !@contents.disposed?
        @sprites["scroll0"].visible = @visible && hascontents && @oy > 0
        @sprites["scroll1"].visible = @visible && hascontents && @ox > 0
        @sprites["scroll2"].visible = @visible && (@contents.width - @ox) > @width-trimWidth
        @sprites["scroll3"].visible = @visible && (@contents.height - @oy) > @height-trimHeight
      end
    end
    if @_windowskin && !@_windowskin.disposed?
      borderX=startX+endX
      borderY=startY+endY
      @sprites["corner0"].x=@x
      @sprites["corner0"].y=@y
      @sprites["corner1"].x=@x+@width-endX
      @sprites["corner1"].y=@y
      @sprites["corner2"].x=@x
      @sprites["corner2"].y=@y+@height-endY
      @sprites["corner3"].x=@x+@width-endX
      @sprites["corner3"].y=@y+@height-endY
      @sprites["side0"].x=@x+startX
      @sprites["side0"].y=@y
      @sprites["side1"].x=@x
      @sprites["side1"].y=@y+startY
      @sprites["side2"].x=@x+@width-endX
      @sprites["side2"].y=@y+startY
      @sprites["side3"].x=@x+startX
      @sprites["side3"].y=@y+@height-endY
      @sprites["scroll0"].x = @x+@width / 2 - 8
      @sprites["scroll0"].y = @y+8
      @sprites["scroll1"].x = @x+8
      @sprites["scroll1"].y = @y+@height / 2 - 8
      @sprites["scroll2"].x = @x+@width - 16
      @sprites["scroll2"].y = @y+@height / 2 - 8
      @sprites["scroll3"].x = @x+@width / 2 - 8
      @sprites["scroll3"].y = @y+@height - 16
      @sprites["cursor"].x=@x+startX+@cursor_rect.x
      @sprites["cursor"].y=@y+startY+@cursor_rect.y
      if (@compat & CompatBits::ExpandBack)>0 && @skinformat==0
        # Compatibility mode: Expand background
        @sprites["back"].x=@x+2
        @sprites["back"].y=@y+2
      else
        @sprites["back"].x=@x+startX
        @sprites["back"].y=@y+startY
      end
    end
    if changeBitmap && @_windowskin && !@_windowskin.disposed?
      if @skinformat==0
        @sprites["cursor"].x=@x+startX+@cursor_rect.x
        @sprites["cursor"].y=@y+startY+@cursor_rect.y
        width=@cursor_rect.width
        height=@cursor_rect.height
        if width > 0 && height > 0
          cursorrects=[
             # sides
             Rect.new(cursorX+2, cursorY+0, 28, 2),
             Rect.new(cursorX+0, cursorY+2, 2, 28),
             Rect.new(cursorX+30, cursorY+2, 2, 28),
             Rect.new(cursorX+2, cursorY+30, 28, 2),
             # corners
             Rect.new(cursorX+0, cursorY+0, 2, 2),
             Rect.new(cursorX+30, cursorY+0, 2, 2),
             Rect.new(cursorX+0, cursorY+30, 2, 2),
             Rect.new(cursorX+30, cursorY+30, 2, 2),
             # back
             Rect.new(cursorX+2, cursorY+2, 28, 28)
          ]
          margin=2
          fullmargin=4
          @cursorbitmap = ensureBitmap(@cursorbitmap, width, height)
          @cursorbitmap.clear
          @sprites["cursor"].bitmap=@cursorbitmap
          @sprites["cursor"].src_rect.set(0,0,width,height)
          rect = Rect.new(margin,margin,width - fullmargin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[8])
          @cursorbitmap.blt(0, 0, @_windowskin, cursorrects[4])# top left
          @cursorbitmap.blt(width-margin, 0, @_windowskin, cursorrects[5]) # top right
          @cursorbitmap.blt(0, height-margin, @_windowskin, cursorrects[6]) # bottom right
          @cursorbitmap.blt(width-margin, height-margin, @_windowskin, cursorrects[7]) # bottom left
          rect = Rect.new(margin, 0,width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[0])
          rect = Rect.new(0, margin,margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[1])
          rect = Rect.new(width - margin, margin, margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[2])
          rect = Rect.new(margin, height-margin, width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[3])
        else
          @sprites["cursor"].visible=false
          @sprites["cursor"].src_rect.set(0,0,0,0)
        end
      end
      for i in 0..3
        case i
        when 0
          dwidth  = @width-startX-endX
          dheight = startY
        when 1
          dwidth  = startX
          dheight = @height-startY-endY
        when 2
          dwidth  = endX
          dheight = @height-startY-endY
        when 3
          dwidth  = @width-startX-endX
          dheight = endY
        end
        @sidebitmaps[i]=ensureBitmap(@sidebitmaps[i],dwidth,dheight)
        @sprites["side#{i}"].bitmap=@sidebitmaps[i]
        @sprites["side#{i}"].src_rect.set(0,0,dwidth,dheight)
        @sidebitmaps[i].clear
        if sideRects[i].width>0 && sideRects[i].height>0
          if (@compat & CompatBits::StretchSides)>0 && @skinformat==0
            # Compatibility mode: Stretch sides
            @sidebitmaps[i].stretch_blt(@sprites["side#{i}"].src_rect,
               @_windowskin,sideRects[i])
          else
            tileBitmap(@sidebitmaps[i],@sprites["side#{i}"].src_rect,
               @_windowskin,sideRects[i])
          end
        end
      end
      if (@compat & CompatBits::ExpandBack)>0 && @skinformat==0
        # Compatibility mode: Expand background
        backwidth=@width-4
        backheight=@height-4
      else
        backwidth=@width-borderX
        backheight=@height-borderY
      end
      if backwidth>0 && backheight>0
        @backbitmap=ensureBitmap(@backbitmap,backwidth,backheight)
        @sprites["back"].bitmap=@backbitmap
        @sprites["back"].src_rect.set(0,0,backwidth,backheight)
        @backbitmap.clear
        if @stretch
          @backbitmap.stretch_blt(@sprites["back"].src_rect,@_windowskin,backRect)
        else
          tileBitmap(@backbitmap,@sprites["back"].src_rect,@_windowskin,backRect)
        end
        if blindsRect
          tileBitmap(@backbitmap,@sprites["back"].src_rect,@_windowskin,blindsRect)
        end
      else
        @sprites["back"].visible=false
        @sprites["back"].src_rect.set(0,0,0,0)
      end
    end
    if @openness!=255
      opn=@openness/255.0
      for k in @spritekeys
        sprite=@sprites[k]
        ratio=(@height<=0) ? 0 : (sprite.y-@y)*1.0/@height
        sprite.zoom_y=opn
        sprite.zoom_x=1.0
        sprite.oy=0
        sprite.y=(@y+(@height/2.0)+(@height*ratio*opn)-(@height/2*opn)).floor
      end
    else
      for k in @spritekeys
        sprite=@sprites[k]
        sprite.zoom_x=1.0
        sprite.zoom_y=1.0
      end
    end
    i=0
    # Ensure Z order
    for k in @spritekeys
      sprite=@sprites[k]
      y=sprite.y
      sprite.y=i
      sprite.oy=(sprite.zoom_y<=0) ? 0 : (i-y)/sprite.zoom_y
      sprite.zoom_x*=@zoom_x
      sprite.zoom_y*=@zoom_y
      sprite.x*=@zoom_x
      sprite.y*=@zoom_y
      sprite.x+=(@offset_x/sprite.zoom_x)
      sprite.y+=(@offset_y/sprite.zoom_y)
    end
  end
end



#===============================================================================
#
#===============================================================================
class SpriteWindow_Base < SpriteWindow
  TEXTPADDING=4   # In pixels

  def initialize(x, y, width, height)
    super()
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    @curframe=MessageConfig.pbGetSystemFrame()
    @curfont=MessageConfig.pbGetSystemFontName()
    @sysframe=AnimatedBitmap.new(@curframe)
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
    pbSetSystemFont(self.contents) if self.contents
  end

  def __setWindowskin(skin)
    if skin && (skin.width==192 && skin.height==128) ||  # RPGXP Windowskin
               (skin.width==128 && skin.height==128)     # RPGVX Windowskin
      self.skinformat=0
    else
      self.skinformat=1
    end
    self.windowskin=skin
  end

  def __resolveSystemFrame
    if self.skinformat==1
      if !@resolvedFrame
        @resolvedFrame=MessageConfig.pbGetSystemFrame()
        @resolvedFrame.sub!(/\.[^\.\/\\]+$/,"")
      end
      self.loadSkinFile("#{@resolvedFrame}.txt") if @resolvedFrame!=""
    end
  end

  def setSkin(skin)   # Filename of windowskin to apply. Supports XP, VX, and animated skins.
    @customskin.dispose if @customskin
    @customskin=nil
    resolvedName=pbResolveBitmap(skin)
    return if !resolvedName || resolvedName==""
    @customskin=AnimatedBitmap.new(resolvedName)
    __setWindowskin(@customskin.bitmap)
    if self.skinformat==1
      skinbase=resolvedName.sub(/\.[^\.\/\\]+$/,"")
      self.loadSkinFile("#{skinbase}.txt")
    end
  end

  def setSystemFrame
    @customskin.dispose if @customskin
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
  end

  def update
    super
    if self.windowskin
      if @customskin
        if @customskin.totalFrames>1
          @customskin.update
          __setWindowskin(@customskin.bitmap)
        end
      elsif @sysframe
        if @sysframe.totalFrames>1
          @sysframe.update
          __setWindowskin(@sysframe.bitmap)
        end
      end
    end
    if @curframe!=MessageConfig.pbGetSystemFrame()
      @curframe=MessageConfig.pbGetSystemFrame()
      if @sysframe && !@customskin
        @sysframe.dispose if @sysframe
        @sysframe=AnimatedBitmap.new(@curframe)
        @resolvedFrame=nil
        __setWindowskin(@sysframe.bitmap)
        __resolveSystemFrame()
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
    if @curfont!=MessageConfig.pbGetSystemFontName()
      @curfont=MessageConfig.pbGetSystemFontName()
      if self.contents && !self.contents.disposed?
        pbSetSystemFont(self.contents)
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
  end

  def dispose
    self.contents.dispose if self.contents
    @sysframe.dispose
    @customskin.dispose if @customskin
    super
  end
end



#===============================================================================
#
#===============================================================================
# Represents a window with no formatting capabilities.  Its text color can be set,
# though, and line breaks are supported, but the text is generally unformatted.
class Window_UnformattedTextPokemon < SpriteWindow_Base
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  # Letter-by-letter mode.  This mode is not supported in this class.
  attr_accessor :letterbyletter

  def text=(value)
    @text=value
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def initialize(text="")
    super(0,0,33,33)
    self.contents=Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    @text=text
    @letterbyletter=false # Not supported in this class
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    resizeToFit(text)
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret=self.new(text)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    ret.refresh
    return ret
  end

  def resizeToFitInternal(text,maxwidth) # maxwidth is maximum acceptable window width
    dims=[0,0]
    cwidth=maxwidth<0 ? Graphics.width : maxwidth
    getLineBrokenChunks(self.contents,text,
       cwidth-self.borderX-SpriteWindow_Base::TEXTPADDING,dims,true)
    return dims
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text=text
  end

  def resizeToFit(text,maxwidth=-1) # maxwidth is maximum acceptable window width
    dims=resizeToFitInternal(text,maxwidth)
    self.width=dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    self.height=dims[1]+self.borderY
    refresh
  end

  def resizeHeightToFit(text,width=-1)   # width is current window width
    dims=resizeToFitInternal(text,width)
    self.width=width<0 ? Graphics.width : width
    self.height=dims[1]+self.borderY
    refresh
  end

  def setSkin(skin)
    super(skin)
    privRefresh(true)
    oldbaser = @baseColor.red
    oldbaseg = @baseColor.green
    oldbaseb = @baseColor.blue
    oldbasea = @baseColor.alpha
    oldshadowr = @shadowColor.red
    oldshadowg = @shadowColor.green
    oldshadowb = @shadowColor.blue
    oldshadowa = @shadowColor.alpha
    colors = getDefaultTextColors(self.windowskin)
    @baseColor   = colors[0]
    @shadowColor = colors[1]
    if oldbaser!=@baseColor.red || oldbaseg!=@baseColor.green ||
       oldbaseb!=@baseColor.blue || oldbasea!=@baseColor.alpha ||
       oldshadowr!=@shadowColor.red || oldshadowg!=@shadowColor.green ||
       oldshadowb!=@shadowColor.blue || oldshadowa!=@shadowColor.alpha
      self.text = self.text
    end
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    self.contents.clear
    drawTextEx(self.contents,0,0,self.contents.width,0,
       @text.gsub(/\r/,""),@baseColor,@shadowColor)
  end
end



#===============================================================================
#
#===============================================================================
class Window_AdvancedTextPokemon < SpriteWindow_Base
  attr_reader   :text
  attr_reader   :baseColor
  attr_reader   :shadowColor
  attr_accessor :letterbyletter
  attr_reader   :waitcount

  def initialize(text="")
    @cursorMode       = MessageConfig::CURSORMODE
    @endOfText        = nil
    @scrollstate      = 0
    @realframes       = 0
    @scrollY          = 0
    @nodraw           = false
    @lineHeight       = 32
    @linesdrawn       = 0
    @bufferbitmap     = nil
    @letterbyletter   = false
    @starting         = true
    @displaying       = false
    @lastDrawnChar    = -1
    @fmtchars         = []
    @frameskipChanged = false
    @frameskip        = MessageConfig.pbGetTextSpeed()
    super(0,0,33,33)
    @pausesprite      = nil
    @text             = ""
    self.contents = Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    self.resizeToFit(text,Graphics.width)
    colors = getDefaultTextColors(self.windowskin)
    @baseColor        = colors[0]
    @shadowColor      = colors[1]
    self.text         = text
    @starting         = false
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret = self.new(text)
    ret.x        = x
    ret.y        = y
    ret.width    = width
    ret.height   = height
    ret.viewport = viewport
    return ret
  end

  def dispose
    return if disposed?
    @pausesprite.dispose if @pausesprite
    @pausesprite = nil
    super
  end

  def waitcount=(value)
    @waitcount = (value<=0) ? 0 : value
  end

  attr_reader :cursorMode

  def cursorMode=(value)
    @cursorMode = value
    moveCursor
  end

  def lineHeight(value)
    @lineHeight = value
    self.text = self.text
  end

  def baseColor=(value)
    @baseColor = value
    refresh
  end

  def shadowColor=(value)
    @shadowColor = value
    refresh
  end

  def textspeed
    @frameskip
  end

  def textspeed=(value)
    @frameskipChanged = true if @frameskip!=value
    @frameskip = value
  end

  def width=(value)
    super
    self.text = self.text if !@starting
  end

  def height=(value)
    super
    self.text = self.text if !@starting
  end

  def resizeToFit(text,maxwidth=-1)
    dims = resizeToFitInternal(text,maxwidth)
    oldstarting = @starting
    @starting = true
    self.width  = dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    self.height = dims[1]+self.borderY
    @starting = oldstarting
    redrawText
  end

  def resizeToFit2(text,maxwidth,maxheight)
    dims = resizeToFitInternal(text,maxwidth)
    oldstarting = @starting
    @starting = true
    self.width  = [dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING,maxwidth].min
    self.height = [dims[1]+self.borderY,maxheight].min
    @starting = oldstarting
    redrawText
  end

  def resizeToFitInternal(text,maxwidth)
    dims = [0,0]
    cwidth = (maxwidth<0) ? Graphics.width : maxwidth
    chars = getFormattedTextForDims(self.contents,0,0,
       cwidth-self.borderX-2-6,-1,text,@lineHeight,true)
    for ch in chars
      dims[0] = [dims[0],ch[1]+ch[3]].max
      dims[1] = [dims[1],ch[2]+ch[4]].max
    end
    return dims
  end

  def resizeHeightToFit(text,width=-1)
    dims = resizeToFitInternal(text,width)
    oldstarting = @starting
    @starting = true
    self.width  = (width<0) ? Graphics.width : width
    self.height = dims[1]+self.borderY
    @starting = oldstarting
    redrawText
  end

  def setSkin(skin,redrawText=true)
    super(skin)
    privRefresh(true)
    oldbaser = @baseColor.red
    oldbaseg = @baseColor.green
    oldbaseb = @baseColor.blue
    oldbasea = @baseColor.alpha
    oldshadowr = @shadowColor.red
    oldshadowg = @shadowColor.green
    oldshadowb = @shadowColor.blue
    oldshadowa = @shadowColor.alpha
    colors = getDefaultTextColors(self.windowskin)
    @baseColor   = colors[0]
    @shadowColor = colors[1]
    if redrawText &&
       (oldbaser!=@baseColor.red || oldbaseg!=@baseColor.green ||
       oldbaseb!=@baseColor.blue || oldbasea!=@baseColor.alpha ||
       oldshadowr!=@shadowColor.red || oldshadowg!=@shadowColor.green ||
       oldshadowb!=@shadowColor.blue || oldshadowa!=@shadowColor.alpha)
      setText(self.text)
    end
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text = text
  end

  def text=(value)
    setText(value)
  end

  def setText(value)
    @waitcount     = 0
    @curchar       = 0
    @drawncurchar  = -1
    @lastDrawnChar = -1
    @text          = value
    @textlength    = unformattedTextLength(value)
    @scrollstate   = 0
    @scrollY       = 0
    @linesdrawn    = 0
    @realframes    = 0
    @textchars     = []
    width  = 1
    height = 1
    numlines = 0
    visiblelines = (self.height-self.borderY)/32
    if value.length==0
      @fmtchars     = []
      @bitmapwidth  = width
      @bitmapheight = height
      @numtextchars = 0
    else
      if @letterbyletter
        @fmtchars = []
        fmt = getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont = self.contents.font.clone
        for ch in fmt
          chx = ch[1]+ch[3]
          chy = ch[2]+ch[4]
          width  = chx if width<chx
          height = chy if height<chy
          if !ch[5] && ch[0]=="\n"
            numlines += 1
            if numlines>=visiblelines
              fclone = ch.clone
              fclone[0] = "\1"
              @fmtchars.push(fclone)
              @textchars.push("\1")
            end
          end
          # Don't add newline characters, since they
          # can slow down letter-by-letter display
          if ch[5] || (ch[0]!="\r")
            @fmtchars.push(ch)
            @textchars.push(ch[5] ? "" : ch[0])
          end
        end
        fmt.clear
      else
        @fmtchars = getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont = self.contents.font.clone
        for ch in @fmtchars
          chx = ch[1]+ch[3]
          chy = ch[2]+ch[4]
          width  = chx if width<chx
          height = chy if height<chy
          @textchars.push(ch[5] ? "" : ch[0])
        end
      end
      @bitmapwidth  = width
      @bitmapheight = height
      @numtextchars = @textchars.length
    end
    stopPause
    @displaying = @letterbyletter
    @needclear  = true
    @nodraw     = @letterbyletter
    refresh
  end

  def busy?
    return @displaying
  end

  def pausing?
    return @pausing && @displaying
  end

  def resume
    if !busy?
      self.stopPause
      return true
    end
    if @pausing
      @pausing = false
      self.stopPause
      return false
    end
    return true
  end

  def position
    return 0 if @lastDrawnChar<0
    return @numtextchars if @lastDrawnChar>=@fmtchars.length
    # index after the last character's index
    return @fmtchars[@lastDrawnChar][14]+1
  end

  def maxPosition
    pos = 0
    for ch in @fmtchars
      # index after the last character's index
      pos = ch[14]+1 if pos<ch[14]+1
    end
    return pos
  end

  def skipAhead
    return if !busy?
    return if @textchars[@curchar]=="\n"
    resume
    visiblelines = (self.height-self.borderY)/@lineHeight
    loop do
      curcharSkip(999)
      break if @curchar>=@fmtchars.length    # End of message
      if @textchars[@curchar]=="\1"          # Pause message
        @pausing = true if @curchar<@numtextchars-1
        self.startPause
        refresh
        break
      end
      break if @textchars[@curchar]!="\n"    # Skip past newlines only
      break if @linesdrawn>=visiblelines-1   # No more empty lines to continue to
      @linesdrawn += 1
    end
  end

  def allocPause
    return if @pausesprite
    @pausesprite = AnimatedSprite.create("Graphics/Pictures/pause",4,3)
    @pausesprite.z       = 100000
    @pausesprite.visible = false
  end

  def startPause
    allocPause
    @pausesprite.visible = true
    @pausesprite.frame   = 0
    @pausesprite.start
    moveCursor
  end

  def stopPause
    return if !@pausesprite
    @pausesprite.stop
    @pausesprite.visible = false
  end

  def moveCursor
    return if !@pausesprite
    cursor = @cursorMode
    cursor = 2 if cursor==0 && !@endOfText
    case cursor
    when 0   # End of text
      @pausesprite.x = self.x+self.startX+@endOfText.x+@endOfText.width-2
      @pausesprite.y = self.y+self.startY+@endOfText.y-@scrollY
    when 1   # Lower right
      pauseWidth  = @pausesprite.bitmap ? @pausesprite.framewidth : 16
      pauseHeight = @pausesprite.bitmap ? @pausesprite.frameheight : 16
      @pausesprite.x = self.x+self.width-(20*2)+(pauseWidth/2)
      @pausesprite.y = self.y+self.height-(30*2)+(pauseHeight/2)
    when 2   # Lower middle
      pauseWidth  = @pausesprite.bitmap ? @pausesprite.framewidth : 16
      pauseHeight = @pausesprite.bitmap ? @pausesprite.frameheight : 16
      @pausesprite.x = self.x+(self.width/2)-(pauseWidth/2)
      @pausesprite.y = self.y+self.height-(18*2)+(pauseHeight/2)
    end
  end

  def refresh
    oldcontents = self.contents
    self.contents = pbDoEnsureBitmap(oldcontents,@bitmapwidth,@bitmapheight)
    self.oy       = @scrollY
    numchars = @numtextchars
    numchars = [@curchar,@numtextchars].min if self.letterbyletter
    return if busy? && @drawncurchar==@curchar && @scrollstate==0
    if !self.letterbyletter || !oldcontents.equal?(self.contents)
      @drawncurchar = -1
      @needclear    = true
    end
    if @needclear
      self.contents.font = @oldfont if @oldfont
      self.contents.clear
      @needclear = false
    end
    if @nodraw
      @nodraw = false
      return
    end
    maxX = self.width-self.borderX
    maxY = self.height-self.borderY
    for i in @drawncurchar+1..numchars
      next if i>=@fmtchars.length
      if !self.letterbyletter
        next if @fmtchars[i][1]>=maxX
        next if @fmtchars[i][2]>=maxY
      end
      drawSingleFormattedChar(self.contents,@fmtchars[i])
      @lastDrawnChar = i
    end
    if !self.letterbyletter
      # all characters were drawn, reset old font
      self.contents.font = @oldfont if @oldfont
    end
    if numchars>0 && numchars!=@numtextchars
      fch = @fmtchars[numchars-1]
      if fch
        rcdst = Rect.new(fch[1],fch[2],fch[3],fch[4])
        if @textchars[numchars]=="\1"
          @endOfText = rcdst
          allocPause
          moveCursor
        else
          @endOfText = Rect.new(rcdst.x+rcdst.width,rcdst.y,8,1)
        end
      end
    end
    @drawncurchar = @curchar
  end

  def redrawText
    if @letterbyletter
      oldPosition = self.position
      self.text = self.text
      oldPosition = @numtextchars if oldPosition>@numtextchars
      while self.position!=oldPosition
        refresh
        updateInternal
      end
    else
      self.text = self.text
    end
  end

  def updateInternal
    curcharskip = @frameskip<0 ? @frameskip.abs : 1
    visiblelines = (self.height-self.borderY)/@lineHeight
    if @textchars[@curchar]=="\1"
      if !@pausing
        @realframes += 1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @realframes = 0
        end
      end
    elsif @textchars[@curchar]=="\n"
      if @linesdrawn>=visiblelines-1
        if @scrollstate<@lineHeight
          @scrollstate += [(@lineHeight/4),1].max
          @scrollY     += [(@lineHeight/4),1].max
        end
        if @scrollstate>=@lineHeight
          @realframes += 1
          if @realframes>=@frameskip || @frameskip<0
            curcharSkip(curcharskip)
            @linesdrawn  += 1
            @realframes  = 0
            @scrollstate = 0
          end
        end
      else
        @realframes += 1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @linesdrawn += 1
          @realframes = 0
        end
      end
    elsif @curchar<=@numtextchars
      @realframes += 1
      if @realframes>=@frameskip || @frameskip<0
        curcharSkip(curcharskip)
        @realframes = 0
      end
      if @textchars[@curchar]=="\1"
        @pausing = true if @curchar<@numtextchars-1
        self.startPause
        refresh
      end
    else
      @displaying  = false
      @scrollstate = 0
      @scrollY     = 0
      @linesdrawn  = 0
    end
  end

  def update
    super
    @pausesprite.update if @pausesprite && @pausesprite.visible
    if @waitcount>0
      @waitcount -= 1
      return
    end
    if busy?
      refresh if !@frameskipChanged
      updateInternal
      # following line needed to allow "textspeed=-999" to work seamlessly
      refresh if @frameskipChanged
    end
    @frameskipChanged = false
  end

  private

  def curcharSkip(skip)
    skip.times do
      @curchar += 1
      break if @textchars[@curchar]=="\n" ||   # newline
               @textchars[@curchar]=="\1" ||   # pause
               @textchars[@curchar]=="\2" ||   # letter-by-letter break
               @textchars[@curchar]==nil
    end
  end
end



#===============================================================================
#
#===============================================================================
class Window_InputNumberPokemon < SpriteWindow_Base
  attr_reader :sign

  def initialize(digits_max)
    @digits_max=digits_max
    @number=0
    @frame=0
    @sign=false
    @negative=false
    super(0,0,32,32)
    self.width=digits_max*24+8+self.borderX
    self.height=32+self.borderY
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    @index=digits_max-1
    self.active=true
    refresh
  end

  def active=(value)
    super
    refresh
  end

  def number
    @number*(@sign && @negative ? -1 : 1)
  end

  def number=(value)
    value=0 if !value.is_a?(Numeric)
    if @sign
      @negative=(value<0)
      @number = [value.abs, 10 ** @digits_max - 1].min
    else
      @number = [[value, 0].max, 10 ** @digits_max - 1].min
    end
    refresh
  end

  def sign=(value)
    @sign=value
    self.width=@digits_max*24+8+self.borderX+(@sign ? 24 : 0)
    @index=(@digits_max-1)+(@sign ? 1 : 0)
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,
       self.width-self.borderX,self.height-self.borderY)
    pbSetSystemFont(self.contents)
    self.contents.clear
    s=sprintf("%0*d",@digits_max,@number.abs)
    if @sign
      textHelper(0,0,@negative ? "-" : "+",0)
    end
    for i in 0...@digits_max
      index=i+(@sign ? 1 : 0)
      textHelper(index*24,0,s[i,1],index)
    end
  end

  def update
    super
    digits=@digits_max+(@sign ? 1 : 0)
    refresh if @frame%15==0
    if self.active
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        if @index==0 && @sign
          @negative=!@negative
        else
          place = 10 ** (digits - 1 - @index)
          n = @number / place % 10
          @number -= n*place
          if Input.repeat?(Input::UP)
            n = (n + 1) % 10
          elsif Input.repeat?(Input::DOWN)
            n = (n + 9) % 10
          end
          @number += n*place
        end
        refresh
      elsif Input.repeat?(Input::RIGHT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + 1) % digits
          @frame=0
          refresh
        end
      elsif Input.repeat?(Input::LEFT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + digits - 1) % digits
          @frame=0
          refresh
        end
      end
    end
    @frame=(@frame+1)%30
  end

  private

  def textHelper(x,y,text,i)
    textwidth=self.contents.text_size(text).width
    self.contents.font.color=@shadowColor
    pbDrawShadow(self.contents,x+(12-textwidth/2),y, textwidth+4, 32, text)
    self.contents.font.color=@baseColor
    self.contents.draw_text(x+(12-textwidth/2),y, textwidth+4, 32, text)
    if @index==i && @active && @frame/15==0
      colors=getDefaultTextColors(self.windowskin)
      self.contents.fill_rect(x+(12-textwidth/2),y+30,textwidth,2,colors[0])
    end
  end
end



#===============================================================================
#
#===============================================================================
class SpriteWindow_Selectable < SpriteWindow_Base
  attr_reader :index

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @virtualOy=0
    @index = -1
    @row_height = 32
    @column_spacing = 32
    @ignore_input = false
  end

  def itemCount
    return @item_max || 0
  end

  def index=(index)
    if @index!=index
      @index = index
      priv_update_cursor_rect(true)
    end
  end

  def rowHeight
    return @row_height || 32
  end

  def rowHeight=(value)
    if @row_height!=value
      oldTopRow=self.top_row
      @row_height=[1,value].max
      self.top_row=oldTopRow
      update_cursor_rect
    end
  end

  def columns
    return @column_max || 1
  end

  def columns=(value)
    if @column_max!=value
      @column_max=[1,value].max
      update_cursor_rect
    end
  end

  def columnSpacing
    return @column_spacing || 32
  end

  def columnSpacing=(value)
    if @column_spacing!=value
      @column_spacing=[0,value].max
      update_cursor_rect
    end
  end

  def ignore_input=(value)
    @ignore_input=value
  end

  def count
    return @item_max
  end

  def row_max
    return ((@item_max + @column_max - 1) / @column_max).to_i
  end

  def top_row
    return (@virtualOy / (@row_height || 32)).to_i
  end

  def top_row=(row)
    row = row_max-1 if row>row_max-1
    row = 0 if row<0
    @virtualOy = row*@row_height
  end

  def top_item
    return top_row * @column_max
  end

  def page_row_max
    return priv_page_row_max.to_i
  end

  def page_item_max
    return priv_page_item_max.to_i
  end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def refresh; end

  def update_cursor_rect
    priv_update_cursor_rect
  end

  def update
    super
    if self.active and @item_max > 0 and @index >= 0 and !@ignore_input
      if Input.repeat?(Input::UP)
        if @index >= @column_max or
           (Input.trigger?(Input::UP) && (@item_max%@column_max)==0)
          oldindex = @index
          @index = (@index - @column_max + @item_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::DOWN)
        if @index < @item_max - @column_max or
           (Input.trigger?(Input::DOWN) && (@item_max%@column_max)==0)
          oldindex = @index
          @index = (@index + @column_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::LEFT)
        if @column_max >= 2 and @index > 0
          oldindex = @index
          @index -= 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::RIGHT)
        if @column_max >= 2 and @index < @item_max - 1
          oldindex = @index
          @index += 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::L)
        if @index > 0
          oldindex = @index
          @index = [self.index-self.page_item_max, 0].max
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row -= self.page_row_max
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::R)
        if @index < @item_max-1
          oldindex = @index
          @index = [self.index+self.page_item_max, @item_max-1].min
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row += self.page_row_max
            update_cursor_rect
          end
        end
      end
    end
  end

  private

  def priv_page_row_max
    return (self.height - self.borderY) / @row_height
  end

  def priv_page_item_max
    return (self.height - self.borderY) / @row_height * @column_max
  end

  def priv_update_cursor_rect(force=false)
    if @index < 0
      self.cursor_rect.empty
      self.refresh
      return
    end
    dorefresh = false
    row = @index / @column_max
    # This code makes lists scroll only when the cursor hits the top and bottom
    # of the visible list.
#    if row < self.top_row
#      self.top_row = row
#      dorefresh=true
#    end
#    if row > self.top_row + (self.page_row_max - 1)
#      self.top_row = row - (self.page_row_max - 1)
#      dorefresh=true
#    end
#    if oldindex-self.top_item>=((self.page_item_max - 1)/2)
#      self.top_row+=1
#    end
#    self.top_row = [self.top_row, self.row_max - self.page_row_max].min
    # This code makes the cursor stay in the middle of the visible list as much
    # as possible.
    new_top_row = row - ((self.page_row_max - 1)/2).floor
    new_top_row = [[new_top_row, self.row_max - self.page_row_max].min, 0].max
    if self.top_row != new_top_row
      self.top_row = new_top_row
#      dorefresh = true
    end
    # End of code
    cursor_width = (self.width-self.borderX) / @column_max
    x = self.index % @column_max * (cursor_width + @column_spacing)
    y = self.index / @column_max * @row_height - @virtualOy
    self.cursor_rect.set(x, y, cursor_width, @row_height)
    self.refresh if dorefresh || force
  end
end



#===============================================================================
#
#===============================================================================
module UpDownArrowMixin
  def initUpDownArrow
    @uparrow   = AnimatedSprite.create("Graphics/Pictures/uparrow",8,2,self.viewport)
    @downarrow = AnimatedSprite.create("Graphics/Pictures/downarrow",8,2,self.viewport)
    @uparrow.z   = 99998
    @downarrow.z = 99998
    @uparrow.visible   = false
    @downarrow.visible = false
    @uparrow.play
    @downarrow.play
  end

  def dispose
    @uparrow.dispose
    @downarrow.dispose
    super
  end

  def viewport=(value)
    super
    @uparrow.viewport   = self.viewport
    @downarrow.viewport = self.viewport
  end

  def color=(value)
    super
    @uparrow.color   = value
    @downarrow.color = value
  end

  def adjustForZoom(sprite)
    sprite.zoom_x = self.zoom_x
    sprite.zoom_y = self.zoom_y
    sprite.x = sprite.x*self.zoom_x + self.offset_x/self.zoom_x
    sprite.y = sprite.y*self.zoom_y + self.offset_y/self.zoom_y
  end

  def update
    super
    @uparrow.x   = self.x+(self.width/2)-(@uparrow.framewidth/2)
    @downarrow.x = self.x+(self.width/2)-(@downarrow.framewidth/2)
    @uparrow.y   = self.y
    @downarrow.y = self.y+self.height-@downarrow.frameheight
    @uparrow.visible = self.visible && self.active && (self.top_item!=0 &&
                       @item_max > self.page_item_max)
    @downarrow.visible = self.visible && self.active &&
                         (self.top_item+self.page_item_max<@item_max && @item_max > self.page_item_max)
    @uparrow.z   = self.z+1
    @downarrow.z = self.z+1
    adjustForZoom(@uparrow)
    adjustForZoom(@downarrow)
    @uparrow.viewport   = self.viewport
    @downarrow.viewport = self.viewport
    @uparrow.update
    @downarrow.update
  end
end



#===============================================================================
#
#===============================================================================
class SpriteWindow_SelectableEx < SpriteWindow_Selectable
  include UpDownArrowMixin

  def initialize(*arg)
    super(*arg)
    initUpDownArrow
  end
end



#===============================================================================
#
#===============================================================================
class Window_DrawableCommand < SpriteWindow_SelectableEx
  attr_reader :baseColor
  attr_reader :shadowColor

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport = viewport if viewport
    if isDarkWindowskin(self.windowskin)
      @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow_white")
    else
      @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
    end
    @index = 0
    colors = getDefaultTextColors(self.windowskin)
    @baseColor   = colors[0]
    @shadowColor = colors[1]
    refresh
  end

  def dispose
    @selarrow.dispose
    super
  end

  def baseColor=(value)
    @baseColor = value
    refresh
  end

  def shadowColor=(value)
    @shadowColor = value
    refresh
  end

  def textWidth(bitmap,text)
    return bitmap.text_size(text).width
  end

  def getAutoDims(commands,dims,width=nil)
    rowMax = ((commands.length + self.columns - 1) / self.columns).to_i
    windowheight = (rowMax*self.rowHeight)
    windowheight += self.borderY
    if !width || width<0
      width=0
      tmpbitmap = BitmapWrapper.new(1,1)
      pbSetSystemFont(tmpbitmap)
      for i in commands
        width = [width,tmpbitmap.text_size(i).width].max
      end
      # one 16 to allow cursor
      width += 16+16+SpriteWindow_Base::TEXTPADDING
      tmpbitmap.dispose
    end
    # Store suggested width and height of window
    dims[0] = [self.borderX+1,(width*self.columns)+self.borderX+
              (self.columns-1)*self.columnSpacing].max
    dims[1] = [self.borderY+1,windowheight].max
    dims[1] = [dims[1],Graphics.height].min
  end

  def setSkin(skin)
    super(skin)
    privRefresh(true)
    colors = getDefaultTextColors(self.windowskin)
    @baseColor   = colors[0]
    @shadowColor = colors[1]
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents,@selarrow.bitmap,rect.x,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end

  def itemCount   # to be implemented by derived classes
    return 0
  end

  def drawItem(index,count,rect)   # to be implemented by derived classes
  end

  def refresh
    @item_max = itemCount()
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i<self.top_item || i>self.top_item+self.page_item_max
      drawItem(i,@item_max,itemRect(i))
    end
  end

  def update
    oldindex = self.index
    super
    refresh if self.index!=oldindex
  end
end



#===============================================================================
#
#===============================================================================
class Window_CommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length
    self.update_cursor_rect
    self.refresh
  end

  def width=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,_count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect=drawCursor(index,rect)
    pbDrawShadowText(self.contents,rect.x,rect.y + (mkxp? ? 6 : 0),rect.width,rect.height,
       @commands[index],self.baseColor,self.shadowColor)
  end
end



#===============================================================================
#
#===============================================================================
class Window_CommandPokemonEx < Window_CommandPokemon
end


#===============================================================================
#
#===============================================================================
class Window_AdvancedCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def textWidth(bitmap,text)
    dims=[nil,0]
    chars=getFormattedText(bitmap,0,0,
       Graphics.width-self.borderX-SpriteWindow_Base::TEXTPADDING-16,
       -1,text,self.rowHeight,true,true)
    for ch in chars
      dims[0]=dims[0] ? [dims[0],ch[1]].min : ch[1]
      dims[1]=[dims[1],ch[1]+ch[3]].max
    end
    dims[0]=0 if !dims[0]
    return dims[1]-dims[0]
  end

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length
    self.update_cursor_rect
    self.refresh
  end

  def width=(value)
    oldvalue=self.width
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    oldvalue=self.height
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,_count,rect)
    pbSetSystemFont(self.contents)
    rect=drawCursor(index,rect)
    if toUnformattedText(@commands[index]).gsub(/\n/,"")==@commands[index]
      # Use faster alternative for unformatted text without line breaks
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],self.baseColor,self.shadowColor)
    else
      chars=getFormattedText(
         self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],rect.height,true,true)
      drawFormattedChars(self.contents,chars)
    end
  end
end



#===============================================================================
#
#===============================================================================
class Window_AdvancedCommandPokemonEx < Window_AdvancedCommandPokemon
end
