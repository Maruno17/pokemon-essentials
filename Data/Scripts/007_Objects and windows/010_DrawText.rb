#===============================================================================
# Text colours
#===============================================================================
def ctag(color)
  ret=(color.red.to_i << 24)
  ret|=((color.green.to_i) << 16)
  ret|=((color.blue.to_i) << 8)
  ret|=((color.alpha.to_i))
  return sprintf("<c=%08X>",ret)
end

def shadowctag(base,shadow)
  return sprintf("<c2=%s%s>",colorToRgb16(base),colorToRgb16(shadow))
end

def shadowc3tag(base,shadow)
  return sprintf("<c3=%s,%s>",colorToRgb32(base),colorToRgb32(shadow))
end

def shadowctagFromColor(color)
  return shadowc3tag(color,getContrastColor(color))
end

def shadowctagFromRgb(param)
  return shadowctagFromColor(rgbToColor(param))
end

def colorToRgb32(color)
  return "" if !color
  if color.alpha.to_i==255
    return sprintf("%02X%02X%02X",color.red.to_i,color.green.to_i,color.blue.to_i)
  else
    return sprintf("%02X%02X%02X%02X",
       color.red.to_i,color.green.to_i,color.blue.to_i,color.alpha.to_i)
  end
end

def colorToRgb16(color)
  ret=(color.red.to_i>>3)
  ret|=((color.green.to_i>>3)<<5)
  ret|=((color.blue.to_i>>3)<<10)
  return sprintf("%04X",ret)
end

def rgbToColor(param)
  return Font.default_color if !param
  baseint=param.to_i(16)
  if param.length==8 # 32-bit hex
    return Color.new(
       (baseint>>24)&0xFF,
       (baseint>>16)&0xFF,
       (baseint>>8)&0xFF,
       (baseint)&0xFF
    )
  elsif param.length==6 # 24-bit hex
    return Color.new(
       (baseint>>16)&0xFF,
       (baseint>>8)&0xFF,
       (baseint)&0xFF
    )
  elsif param.length==4 # 16-bit hex
    return Color.new(
       ((baseint)&0x1F)<<3,
       ((baseint>>5)&0x1F)<<3,
       ((baseint>>10)&0x1F)<<3
    )
  elsif param.length==1 # Color number
     i=param.to_i
     return Font.default_color if i>=8
     return [
        Color.new(255, 255, 255, 255),
        Color.new(128, 128, 255, 255),
        Color.new(255, 128, 128, 255),
        Color.new(128, 255, 128, 255),
        Color.new(128, 255, 255, 255),
        Color.new(255, 128, 255, 255),
        Color.new(255, 255, 128, 255),
        Color.new(192, 192, 192, 255)
     ][i]
  else
    return Font.default_color
  end
end

def Rgb16ToColor(param)
  baseint=param.to_i(16)
  return Color.new(
     ((baseint)&0x1F)<<3,
     ((baseint>>5)&0x1F)<<3,
     ((baseint>>10)&0x1F)<<3
  )
end

def getContrastColor(color)
  raise "No color given" if !color
  r=color.red; g=color.green; b=color.blue
  yuv=[
     r *   0.299 + g * 0.587 + b *  0.114,
     r * -0.1687 + g * -0.3313 + b *  0.500 + 0.5,
     r *   0.500 + g * -0.4187 + b * -0.0813 + 0.5
  ]
  if yuv[0]<127.5
    yuv[0]+=(255-yuv[0])/2
  else
    yuv[0]=yuv[0]/2
  end
  return Color.new(
     yuv[0] + 1.4075 * (yuv[2] - 0.5),
     yuv[0] - 0.3455 * (yuv[1] - 0.5) - 0.7169 * (yuv[2] - 0.5),
     yuv[0] + 1.7790 * (yuv[1] - 0.5),
     color.alpha
  )
end



#===============================================================================
# Format text
#===============================================================================
FORMATREGEXP = /<(\/?)(c|c2|c3|o|fn|br|fs|i|b|r|pg|pog|u|s|icon|img|ac|ar|al|outln|outln2)(\s*\=\s*([^>]*))?>/i

def fmtescape(text)
  if text[/[&<>]/]
    text2=text.gsub(/&/,"&amp;")
    text2.gsub!(/</,"&lt;")
    text2.gsub!(/>/,"&gt;")
    return text2
  end
  return text
end

def toUnformattedText(text)
  text2=text.gsub(FORMATREGEXP,"")
  text2.gsub!(/&lt;/,"<")
  text2.gsub!(/&gt;/,">")
  text2.gsub!(/&apos;/,"'")
  text2.gsub!(/&quot;/,"\"")
  text2.gsub!(/&amp;/,"&")
  return text2
end

def unformattedTextLength(text)
  return toUnformattedText(text).scan(/./m).length
end

def itemIconTag(item)
  return "" if !item
  if item.respond_to?("icon_name")
    return sprintf("<icon=%s>",item.icon_name)
  else
    ix=item.icon_index % 16 * 24
    iy=item.icon_index / 16 * 24
    return sprintf("<img=Graphics/System/Iconset|%d|%d|24|24>",ix,iy)
  end
end

def getFormattedTextForDims(bitmap,xDst,yDst,widthDst,heightDst,text,lineheight,
                            newlineBreaks=true,explicitBreaksOnly=false)
  text2=text.gsub(/<(\/?)(c|c2|c3|o|u|s)(\s*\=\s*([^>]*))?>/i,"")
  if newlineBreaks
    text2.gsub!(/<(\/?)(br)(\s*\=\s*([^>]*))?>/i,"\n")
  end
  return getFormattedText(
     bitmap,xDst,yDst,widthDst,heightDst,
     text2,lineheight,newlineBreaks,
     explicitBreaksOnly,true)
end

def getFormattedTextFast(bitmap,xDst,yDst,widthDst,heightDst,text,lineheight,
                         newlineBreaks=true,explicitBreaksOnly=false)
  x=y=0
  characters=[]
  textchunks=[]
  textchunks.push(text)
  text=textchunks.join("")
  textchars=text.scan(/./m)
  lastword=[0,0] # position of last word
  hadspace=false
  hadnonspace=false
  bold=bitmap.font.bold
  italic=bitmap.font.italic
  colorclone=bitmap.font.color
  defaultfontname=bitmap.font.name
  if defaultfontname.is_a?(Array)
    defaultfontname=defaultfontname.find { |i| Font.exist?(i) } || "Arial"
  elsif !Font.exist?(defaultfontname)
    defaultfontname="Arial"
  end
  defaultfontname=defaultfontname.clone
  havenl=false
  position=0
  while position<textchars.length
    yStart=0
    xStart=0
    width=isWaitChar(textchars[position]) ? 0 : bitmap.text_size(textchars[position]).width
    if textchars[position]=="\n"
      if newlineBreaks   # treat newline as break
        havenl=true
        characters.push(["\n",x,y*lineheight+yDst,0,lineheight,false,false,
           false,colorclone,nil,false,false,"",8,position,nil,0])
        y+=1
        x=0
        hadspace=true
        hadnonspace=false
        position+=1
        next
      else   # treat newline as space
        textchars[position]=" "
      end
    end
    isspace=(textchars[position][/\s/]||isWaitChar(textchars[position]))  ? true : false
    if hadspace && !isspace
      # set last word to here
      lastword[0]=characters.length
      lastword[1]=x
      hadspace=false
      hadnonspace=true
    elsif isspace
      hadspace=true
    end
    texty=(lineheight*y)+yDst+yStart
    # Push character
    if heightDst<0 || yStart<yDst+heightDst
      havenl=true if isWaitChar(textchars[position])
      characters.push([
         textchars[position],
         x+xStart,texty,width+2,lineheight,
         false,bold,italic,colorclone,nil,false,false,
         defaultfontname,bitmap.font.size,position,nil,0])
    end
    x+=width
    if !explicitBreaksOnly && x+2>widthDst && lastword[1]!=0 &&
       (!hadnonspace || !hadspace)
      havenl=true
      characters.insert(lastword[0],["\n",x,y*lineheight+yDst,0,lineheight,
         false,false,false,colorclone,nil,false,false,"",8,position])
      lastword[0]+=1
      y+=1
      x=0
      for i in lastword[0]...characters.length
        characters[i][2]+=lineheight
        charwidth=characters[i][3]-2
        characters[i][1]=x
        x+=charwidth
      end
      lastword[1]=0
    end
    position+=1
  end
  # This code looks at whether the text occupies exactly two lines when
  # displayed. If it does, it balances the length of each line.
=begin
  # Count total number of lines
  numlines = (x==0 && y>0) ? y-1 : y
  realtext = (newlineBreaks) ? text : text.gsub(/\n/," ")
  if numlines==2 && !explicitBreaksOnly && !realtext[/\n/] && realtext.length>=50
    # Set half to middle of text (known to contain no formatting)
    half = realtext.length/2
    leftSearch  = 0
    rightSearch = 0
    # Search left for a space
    i = half; while i>=0
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i])   # found a space
      leftSearch += 1
      i -= 1
    end
    # Search right for a space
    i = half; while i<realtext.length
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i])   # found a space
      rightSearch += 1
      i += 1
    end
    # Move half left or right whichever is closer
    trialHalf = half+((leftSearch<rightSearch) ? -leftSearch : rightSearch)
    if trialHalf!=0 && trialHalf!=realtext.length
      # Insert newline and re-call this function (force explicitBreaksOnly)
      newText = realtext.clone
      newText.insert(trialHalf,"\n")
      return getFormattedTextFast(bitmap,xDst,yDst,
         widthDst,heightDst,newText,lineheight,true,explicitBreaksOnly)
    end
  end
=end
  # Eliminate spaces before newlines and pause character
  if havenl
    firstspace=-1
    for i in 0...characters.length
      if characters[i][5]!=false # If not a character
        firstspace=-1
      elsif (characters[i][0]=="\n" || isWaitChar(characters[i][0])) &&
         firstspace>=0
        for j in firstspace...i
          characters[j]=nil
        end
        firstspace=-1
      elsif characters[i][0][/[ \r\t]/]
        if firstspace<0
          firstspace=i
        end
      else
        firstspace=-1
      end
    end
    if firstspace>0
      for j in firstspace...characters.length
        characters[j]=nil
      end
    end
    characters.compact!
  end
  for i in 0...characters.length
    characters[i][1]=xDst+characters[i][1]
  end
  # Remove all characters with Y greater or equal to _yDst_+_heightDst_
  if heightDst>=0
    for i in 0...characters.length
      if characters[i][2]>=yDst+heightDst
        characters[i]=nil
      end
    end
    characters.compact!
  end
  return characters
end

def isWaitChar(x)
  return (x=="\001" || x=="\002")
end

def getLastParam(array,default)
  i=array.length-1
  while i>=0
    return array[i] if array[i]
    i-=1
  end
  return default
end

def getLastColors(colorstack,opacitystack,defaultcolors)
  colors=getLastParam(colorstack,defaultcolors)
  opacity=getLastParam(opacitystack,255)
  if opacity!=255
    colors=[Color.new(colors[0].red,colors[0].green,colors[0].blue,
       colors[0].alpha*opacity/255),
       colors[1] ? Color.new(colors[1].red,colors[1].green,colors[1].blue,
       colors[1].alpha*opacity/255) : nil]
  end
  return colors
end



#===============================================================================
# Formats a string of text and returns an array containing a list of formatted
# characters.
#===============================================================================
=begin
Parameters:
bitmap:         Source bitmap.  Will be used to determine the default font of
                the text.
xDst:           X coordinate of the text's top left corner.
yDst:           Y coordinate of the text's top left corner.
widthDst:       Width of the text.  Used to determine line breaks.
heightDst:      Height of the text.  If -1, there is no height restriction.  If
                1 or greater, any characters exceeding the height are removed
                from the returned list.
newLineBreaks:  If true, newline characters will be treated as line breaks. The
                default is true.

Return Values:
A list of formatted characters.  Returns an empty array if _bitmap_ is nil
or disposed, or if _widthDst_ is 0 or less or _heightDst_ is 0.

Formatting Specification:
This function uses the following syntax when formatting the text.
<b> ... </b>       - Formats the text in bold.
<i> ... </i>       - Formats the text in italics.
<u> ... </u>       - Underlines the text.
<s> ... </s>       - Draws a strikeout line over the text.
<al> ... </al>     - Left-aligns the text.  Causes line breaks before and after
                     the text.
<r>                - Right-aligns the text until the next line break.
<ar> ... </ar>     - Right-aligns the text.  Causes line breaks before and after
                     the text.
<ac> ... </ac>     - Centers the text.  Causes line breaks before and after the
                     text.
<br>               - Causes a line break.
<c=X> ... </c>     - Color specification.  A total of four formats are supported:
                     RRGGBBAA, RRGGBB, 16-bit RGB, and Window_Base color numbers.
<c2=X> ... </c2>   - Color specification where the first half is the base color
                     and the second half is the shadow color.  16-bit RGB is
                     supported.
Added 2009-10-20
<c3=B,S> ... </c3> - Color specification where B is the base color and S is the
                     shadow color.  B and/or S can be omitted.  A total of four
                     formats are supported:
                     RRGGBBAA, RRGGBB, 16-bit RGB, and Window_Base color numbers.
Added 2009-9-12
<o=X>              - Displays the text in the given opacity (0-255)
Added 2009-10-19
<outln>            - Displays the text in outline format.
Added 2010-05-12
<outln2>           - Displays the text in outline format (outlines more
                     exaggerated.
<fn=X> ... </fn>   - Formats the text in the specified font, or Arial if the
                     font doesn't exist.
<fs=X> ... </fs>   - Changes the font size to X.
<icon=X>           - Displays the icon X (in Graphics/Icons/).

In addition, the syntax supports the following:
&apos; - Converted to "'".
&lt;   - Converted to "<".
&gt;   - Converted to ">".
&amp;  - Converted to "&".
&quot; - Converted to double quotation mark.

To draw the characters, pass the returned array to the
_drawFormattedChars_ function.
=end

def getFormattedText(bitmap,xDst,yDst,widthDst,heightDst,text,lineheight=32,
                     newlineBreaks=true,explicitBreaksOnly=false,
                     collapseAlignments=false)
  dummybitmap=nil
  if !bitmap || bitmap.disposed?   # allows function to be called with nil bitmap
    dummybitmap=Bitmap.new(1,1)
    bitmap=dummybitmap
    return
  end
  if !bitmap || bitmap.disposed? || widthDst<=0 || heightDst==0 || text.length==0
    return []
  end
  textchunks=[]
  controls=[]
  oldtext=text
  while text[FORMATREGEXP]
    textchunks.push($~.pre_match)
    if $~[3]
      controls.push([$~[2].downcase,$~[4],-1,$~[1]=="/" ? true : false])
    else
      controls.push([$~[2].downcase,"",-1,$~[1]=="/" ? true : false])
    end
    text=$~.post_match
  end
  if controls.length==0
    ret=getFormattedTextFast(bitmap,xDst,yDst,widthDst,heightDst,text,lineheight,
       newlineBreaks,explicitBreaksOnly)
    dummybitmap.dispose if dummybitmap
    return ret
  end
  x=y=0
  characters=[]
  charactersInternal=[]
  realtext=nil
  realtextStart=""
  if !explicitBreaksOnly && textchunks.join("").length==0
    # All commands occurred at the beginning of the text string
    realtext=(newlineBreaks) ? text : text.gsub(/\n/," ")
    realtextStart=oldtext[0,oldtext.length-realtext.length]
    realtextHalf=text.length/2
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/&lt;/,"<")
    chunk.gsub!(/&gt;/,">")
    chunk.gsub!(/&apos;/,"'")
    chunk.gsub!(/&quot;/,"\"")
    chunk.gsub!(/&amp;/,"&")
  end
  textlen=0
  for i in 0...controls.length
    textlen+=textchunks[i].scan(/./m).length
    controls[i][2]=textlen
  end
  text=textchunks.join("")
  textchars=text.scan(/./m)
  colorstack=[]
  boldcount=0
  italiccount=0
  outlinecount=0
  underlinecount=0
  strikecount=0
  rightalign=0
  outline2count=0
  opacitystack=[]
  oldfont=bitmap.font.clone
  defaultfontname=bitmap.font.name
  defaultfontsize=bitmap.font.size
  fontsize=defaultfontsize
  fontnamestack=[]
  fontsizestack=[]
  defaultcolors=[oldfont.color.clone,nil]
  if defaultfontname.is_a?(Array)
    defaultfontname=defaultfontname.find { |i| Font.exist?(i) } || "Arial"
  elsif !Font.exist?(defaultfontname)
    defaultfontname="Arial"
  end
  defaultfontname=defaultfontname.clone
  fontname=defaultfontname
  alignstack=[]
  lastword=[0,0] # position of last word
  hadspace=false
  hadnonspace=false
  havenl=false
  position=0
  while position<textchars.length
    nextline=0
    graphic=nil
    graphicX=0
    graphicY=4
    graphicWidth=nil
    graphicHeight=nil
    graphicRect=nil
    for i in 0...controls.length
      if controls[i] && controls[i][2]==position
        control=controls[i][0]
        param=controls[i][1]
        endtag=controls[i][3]
        if control=="c"
          if endtag
            colorstack.pop
          else
            color=rgbToColor(param)
            colorstack.push([color,nil])
          end
        elsif control=="c2"
          if endtag
            colorstack.pop
          else
            base=Rgb16ToColor(param[0,4])
            shadow=Rgb16ToColor(param[4,4])
            colorstack.push([base,shadow])
          end
        elsif control=="c3"
          if endtag
            colorstack.pop
          else
            param=param.split(",")
            # get pure colors unaffected by opacity
            oldColors=getLastParam(colorstack,defaultcolors)
            base=(param[0] && param[0]!="") ? rgbToColor(param[0]) : oldColors[0]
            shadow=(param[1] && param[1]!="") ? rgbToColor(param[1]) : oldColors[1]
            colorstack.push([base,shadow])
          end
        elsif control=="o"
          if endtag
            opacitystack.pop
          else
            opacitystack.push(param.sub(/\s+$/,"").to_i)
          end
        elsif control=="b"
          boldcount+=(endtag ? -1 : 1)
        elsif control=="i"
          italiccount+=(endtag ? -1 : 1)
        elsif control=="u"
          underlinecount+=(endtag ? -1 : 1)
        elsif control=="s"
          strikecount+=(endtag ? -1 : 1)
        elsif control=="outln"
          outlinecount+=(endtag ? -1 : 1)
        elsif control=="outln2"
          outline2count+=(endtag ? -1 : 1)
        elsif control=="fs" # Font size
          if endtag
            fontsizestack.pop
          else
            fontsizestack.push(param.sub(/\s+$/,"").to_i)
          end
          fontsize=getLastParam(fontsizestack,defaultfontsize)
          bitmap.font.size=fontsize
        elsif control=="fn" # Font name
          if endtag
            fontnamestack.pop
          else
            fontname=param.sub(/\s+$/,"")
            fontnamestack.push(Font.exist?(fontname) ? fontname : "Arial")
          end
          fontname=getLastParam(fontnamestack,defaultfontname)
          bitmap.font.name=fontname
        elsif control=="ar" # Right align
          if !endtag
            alignstack.push(1)
            nextline=1 if x>0 && nextline==0
          else
            alignstack.pop
            nextline=1 if x>0 && nextline==0
          end
        elsif control=="al" # Left align
          if !endtag
            alignstack.push(0)
            nextline=1 if x>0 && nextline==0
          else
            alignstack.pop
            nextline=1 if x>0 && nextline==0
          end
        elsif control=="ac" # Center align
          if !endtag
            alignstack.push(2)
            nextline=1 if x>0 && nextline==0
          else
            alignstack.pop
            nextline=1 if x>0 && nextline==0
          end
        elsif control=="icon" # Icon
          if !endtag
            param=param.sub(/\s+$/,"")
            graphic="Graphics/Icons/#{param}"
            controls[i]=nil
            break
          end
        elsif control=="img" # Icon
          if !endtag
            param=param.sub(/\s+$/,"")
            param=param.split("|")
            graphic=param[0]
            if param.length>1
              graphicX=param[1].to_i
              graphicY=param[2].to_i
              graphicWidth=param[3].to_i
              graphicHeight=param[4].to_i
            end
            controls[i]=nil
            break
          end
        elsif control=="br" # Line break
          if !endtag
            nextline+=1
          end
        elsif control=="r" # Right align this line
          if !endtag
            x=0
            rightalign=1; lastword=[characters.length,x]
          end
        end
        controls[i]=nil
      end
    end
    bitmap.font.bold=(boldcount>0)
    bitmap.font.italic=(italiccount>0)
    if graphic
      if !graphicWidth
        tempgraphic=Bitmap.new(graphic)
        graphicWidth=tempgraphic.width
        graphicHeight=tempgraphic.height
        tempgraphic.dispose
      end
      width=graphicWidth   # +8  # No padding
      xStart=0   # 4
      yStart=[(lineheight/2)-(graphicHeight/2),0].max
      graphicRect=Rect.new(graphicX,graphicY,graphicWidth,graphicHeight)
    else
      xStart=0
      yStart=0
      width=isWaitChar(textchars[position]) ? 0 : bitmap.text_size(textchars[position]).width
      width+=2 if width>0 && outline2count>0
    end
    if rightalign==1 && nextline==0
      alignment=1
    else
      alignment=getLastParam(alignstack,0)
    end
    nextline.times do
      havenl=true
      characters.push(["\n",x,y*lineheight+yDst,0,lineheight,false,false,false,
         defaultcolors[0],defaultcolors[1],false,false,"",8,position,nil,0])
      charactersInternal.push([alignment,y,0])
      y+=1
      x=0
      rightalign=0
      lastword=[characters.length,x]
      hadspace=false
      hadnonspace=false
    end
    if textchars[position]=="\n"
      if newlineBreaks
        if nextline==0
          havenl=true
          characters.push(["\n",x,y*lineheight+yDst,0,lineheight,false,false,false,
             defaultcolors[0],defaultcolors[1],false,false,"",8,position,nil,0])
          charactersInternal.push([alignment,y,0])
          y+=1
          x=0
        end
        rightalign=0
        hadspace=true
        hadnonspace=false
        position+=1
        next
      else
        textchars[position]=" "
        if !graphic
          width=bitmap.text_size(textchars[position]).width
          width+=2 if width>0 && outline2count>0
        end
      end
    end
    isspace=(textchars[position][/\s/] || isWaitChar(textchars[position])) ? true : false
    if hadspace && !isspace
      # set last word to here
      lastword[0]=characters.length
      lastword[1]=x
      hadspace=false
      hadnonspace=true
    elsif isspace
      hadspace=true
    end
    texty=(lineheight*y)+yDst+yStart
    colors=getLastColors(colorstack,opacitystack,defaultcolors)
    # Push character
    if heightDst<0 || texty<yDst+heightDst
      havenl=true if !graphic && isWaitChar(textchars[position])
      extraspace=(!graphic && italiccount>0) ? 2+(width/2) : 2
      characters.push([
         graphic ? graphic : textchars[position],
         x+xStart,texty,width+extraspace,lineheight,
         graphic ? true : false,
         (boldcount>0),(italiccount>0),colors[0],colors[1],
         (underlinecount>0),(strikecount>0),fontname,fontsize,
         position,graphicRect,
         ((outlinecount>0) ? 1 : 0)+((outline2count>0) ? 2 : 0)
      ])
      charactersInternal.push([alignment,y,xStart,textchars[position],extraspace])
    end
    x+=width
    if !explicitBreaksOnly && x+2>widthDst && lastword[1]!=0 &&
       (!hadnonspace || !hadspace)
      havenl=true
      characters.insert(lastword[0],["\n",x,y*lineheight+yDst,0,lineheight,false,
         false,false,defaultcolors[0],defaultcolors[1],false,false,"",8,position,
         nil])
      charactersInternal.insert(lastword[0],[alignment,y,0])
      lastword[0]+=1
      y+=1
      x=0
      for i in lastword[0]...characters.length
        characters[i][2]+=lineheight
        charactersInternal[i][1]+=1
        extraspace=(charactersInternal[i][4]) ? charactersInternal[i][4] : 0
        charwidth=characters[i][3]-extraspace
        characters[i][1]=x+charactersInternal[i][2]
        x+=charwidth
      end
      lastword[1]=0
    end
    position+=1 if !graphic
  end
  # This code looks at whether the text occupies exactly two lines when
  # displayed. If it does, it balances the length of each line.
=begin
  # Count total number of lines
  numlines = (x==0 && y>0) ? y : y+1
  if numlines==2 && realtext && !realtext[/\n/] && realtext.length>=50
    # Set half to middle of text (known to contain no formatting)
    half = realtext.length/2
    leftSearch  = 0
    rightSearch = 0
    # Search left for a space
    i = half; while i>=0
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i,1])   # found a space
      leftSearch += 1
      i -= 1
    end
    # Search right for a space
    i = half; while i<realtext.length
      break if realtext[i,1][/\s/]||isWaitChar(realtext[i,1])   # found a space
      rightSearch += 1
      i += 1
    end
    # Move half left or right whichever is closer
    trialHalf = half+((rightSearch<leftSearch) ? rightSearch : -leftSearch)
    if trialHalf!=0 && trialHalf!=realtext.length
      # Insert newline and re-call this function (force newlineBreaksOnly)
      newText = realtext.clone
      if isWaitChar(newText[trialHalf,1])
        # insert after wait character
        newText.insert(trialHalf+1,"\n")
      else
        # remove spaces after newline
        newText.insert(trialHalf,"\n")
        newText.gsub!(/\n\s+/,"\n")
      end
      bitmap.font = oldfont
      dummybitmap.dispose if dummybitmap
      return getFormattedText(dummybitmap ? nil : bitmap,xDst,yDst,
         widthDst,heightDst,realtextStart+newText,
         lineheight,true,explicitBreaksOnly)
    end
  end
=end
  if havenl
    # Eliminate spaces before newlines and pause character
    firstspace=-1
    for i in 0...characters.length
      if characters[i][5]!=false # If not a character
        firstspace=-1
      elsif (characters[i][0]=="\n" || isWaitChar(characters[i][0])) &&
         firstspace>=0
        for j in firstspace...i
          characters[j]=nil
          charactersInternal[j]=nil
        end
        firstspace=-1
      elsif characters[i][0][/[ \r\t]/]
        if firstspace<0
          firstspace=i
        end
      else
        firstspace=-1
      end
    end
    if firstspace>0
      for j in firstspace...characters.length
        characters[j]=nil
        charactersInternal[j]=nil
      end
    end
    characters.compact!
    charactersInternal.compact!
  end
  # Calculate Xs based on alignment
  # First, find all text runs with the same alignment on the same line
  totalwidth=0
  widthblocks=[]
  lastalign=0
  lasty=0
  runstart=0
  for i in 0...characters.length
    c=characters[i]
    if i>0 && (charactersInternal[i][0]!=lastalign ||
       charactersInternal[i][1]!=lasty)
      # Found end of run
      widthblocks.push([runstart,i,lastalign,totalwidth,lasty])
      runstart=i
      totalwidth=0
    end
    lastalign=charactersInternal[i][0]
    lasty=charactersInternal[i][1]
    extraspace=(charactersInternal[i][4]) ? charactersInternal[i][4] : 0
    totalwidth+=c[3]-extraspace
  end
  widthblocks.push([runstart,characters.length,lastalign,totalwidth,lasty])
  if collapseAlignments
    # Calculate the total width of each line
    totalLineWidths=[]
    for block in widthblocks
      y=block[4]
      if !totalLineWidths[y]
        totalLineWidths[y]=0
      end
      if totalLineWidths[y]!=0
        # padding in case more than one line has different alignments
        totalLineWidths[y]+=16
      end
      totalLineWidths[y]+=block[3]
    end
    # Calculate a new width for the next step
    widthDst=[widthDst,(totalLineWidths.compact.max || 0)].min
  end
  # Now, based on the text runs found, recalculate Xs
  for block in widthblocks
    next if block[0]>=block[1]
    for i in block[0]...block[1]
      case block[2]
      when 1 then characters[i][1] = xDst + (widthDst - block[3] - 4) + characters[i][1]
      when 2 then characters[i][1] = xDst + ((widthDst / 2) - (block[3] / 2)) + characters[i][1]
      else        characters[i][1] = xDst + characters[i][1]
      end
    end
  end
  # Remove all characters with Y greater or equal to _yDst_+_heightDst_
  if heightDst>=0
    for i in 0...characters.length
      if characters[i][2]>=yDst+heightDst
        characters[i]=nil
      end
    end
    characters.compact!
  end
  bitmap.font=oldfont
  dummybitmap.dispose if dummybitmap
  return characters
end



#===============================================================================
# Draw text and images on a bitmap
#===============================================================================
def getLineBrokenText(bitmap,value,width,dims)
  x=0
  y=0
  textheight=0
  ret=[]
  if dims
    dims[0]=0
    dims[1]=0
  end
  line=0
  position=0
  column=0
  return ret if !bitmap || bitmap.disposed? || width<=0
  textmsg=value.clone
  ret.push(["",0,0,0,bitmap.text_size("X").height,0,0,0,0])
  while ((c = textmsg.slice!(/\n|(\S*([ \r\t\f]?))/)) != nil)
    break if c==""
    length=c.scan(/./m).length
    ccheck=c
    if ccheck=="\n"
      ret.push(["\n",x,y,0,textheight,line,position,column,0])
      x=0
      y+=(textheight==0) ? bitmap.text_size("X").height : textheight
      line+=1
      textheight=0
      column=0
      position+=length
      ret.push(["",x,y,0,textheight,line,position,column,0])
      next
    end
    words=[ccheck]
    for i in 0...words.length
      word=words[i]
      if word && word!=""
        textSize=bitmap.text_size(word)
        textwidth=textSize.width
        if x>0 && x+textwidth>=width-2
          # Zero-length word break
          ret.push(["",x,y,0,textheight,line,position,column,0])
          x=0
          column=0
          y+=(textheight==0) ? bitmap.text_size("X").height : textheight
          line+=1
          textheight=0
        end
        textheight=[textheight,textSize.height].max
        ret.push([word,x,y,textwidth,textheight,line,position,column,length])
        x+=textwidth
        dims[0]=x if dims && dims[0]<x
      end
    end
    position+=length
    column+=length
  end
  dims[1]=y+textheight if dims
  return ret
end

def getLineBrokenChunks(bitmap,value,width,dims,plain=false)
  x=0
  y=0
  ret=[]
  if dims
    dims[0]=0
    dims[1]=0
  end
  re=/<c=([^>]+)>/
  reNoMatch=/<c=[^>]+>/
  return ret if !bitmap || bitmap.disposed? || width<=0
  textmsg=value.clone
  color=Font.default_color
  while (c = textmsg.slice!(/\n|[^ \r\t\f\n\-]*\-+|(\S*([ \r\t\f]?))/)) != nil
    break if c==""
    ccheck=c
    if ccheck=="\n"
      x=0
      y+=32
      next
    end
    if ccheck[/</] && !plain
      textcols=[]
      ccheck.scan(re) { textcols.push(rgbToColor($1)) }
      words=ccheck.split(reNoMatch) # must have no matches because split can include match
    else
      textcols=[]
      words=[ccheck]
    end
    for i in 0...words.length
      word=words[i]
      if word && word!=""
        textSize=bitmap.text_size(word)
        textwidth=textSize.width
        if x>0 && x+textwidth>width
          minTextSize=bitmap.text_size(word.gsub(/\s*/,""))
          if x>0 && x+minTextSize.width>width
            x=0
            y+=32
          end
        end
        ret.push([word,x,y,textwidth,32,color])
        x+=textwidth
        dims[0]=x if dims && dims[0]<x
      end
      if textcols[i]
        color=textcols[i]
      end
    end
  end
  dims[1]=y+32 if dims
  return ret
end

def renderLineBrokenChunks(bitmap,xDst,yDst,normtext,maxheight=0)
  for i in 0...normtext.length
    width=normtext[i][3]
    textx=normtext[i][1]+xDst
    texty=normtext[i][2]+yDst
    if maxheight==0 || normtext[i][2]<maxheight
      bitmap.font.color=normtext[i][5]
      bitmap.draw_text(textx,texty,width+2,normtext[i][4],normtext[i][0])
    end
  end
end

def renderLineBrokenChunksWithShadow(bitmap,xDst,yDst,normtext,maxheight,baseColor,shadowColor)
  for i in 0...normtext.length
    width=normtext[i][3]
    textx=normtext[i][1]+xDst
    texty=normtext[i][2]+yDst
    if maxheight==0 || normtext[i][2]<maxheight
      height=normtext[i][4]
      text=normtext[i][0]
      bitmap.font.color=shadowColor
      bitmap.draw_text(textx+2,texty,width+2,height,text)
      bitmap.draw_text(textx,texty+2,width+2,height,text)
      bitmap.draw_text(textx+2,texty+2,width+2,height,text)
      bitmap.font.color=baseColor
      bitmap.draw_text(textx,texty,width+2,height,text)
    end
  end
end

def drawBitmapBuffer(chars)
  width=1
  height=1
  for ch in chars
    chx=ch[1]+ch[3]
    chy=ch[2]+ch[4]
    width=chx if width<chx
    height=chy if height<chy
  end
  buffer=Bitmap.new(width,height)
  drawFormattedChars(buffer,chars)
  return buffer
end

def drawSingleFormattedChar(bitmap,ch)
  if ch[5] # If a graphic
    graphic=Bitmap.new(ch[0])
    graphicRect=ch[15]
    bitmap.blt(ch[1], ch[2], graphic,graphicRect,ch[8].alpha)
    graphic.dispose
  else
    bitmap.font.size=ch[13] if bitmap.font.size!=ch[13]
    if ch[0]!="\n" && ch[0]!="\r" && ch[0]!=" " && !isWaitChar(ch[0])
      bitmap.font.bold=ch[6] if bitmap.font.bold!=ch[6]
      bitmap.font.italic=ch[7] if bitmap.font.italic!=ch[7]
      bitmap.font.name=ch[12] if bitmap.font.name!=ch[12]
      offset=0
      if ch[9] # shadow
        bitmap.font.color=ch[9]
        if (ch[16]&1)!=0 # outline
          offset=1
          bitmap.draw_text(ch[1],ch[2],ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1],ch[2]+1,ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1],ch[2]+2,ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+1,ch[2],ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+1,ch[2]+2,ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2],ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2]+1,ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2]+2,ch[3]+2,ch[4],ch[0])
        elsif (ch[16]&2)!=0 # outline 2
          offset=2
          bitmap.draw_text(ch[1],ch[2],ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1],ch[2]+2,ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1],ch[2]+4,ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2],ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2]+4,ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1]+4,ch[2],ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1]+4,ch[2]+2,ch[3]+4,ch[4],ch[0])
          bitmap.draw_text(ch[1]+4,ch[2]+4,ch[3]+4,ch[4],ch[0])
        else
          bitmap.draw_text(ch[1]+2,ch[2],ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1],ch[2]+2,ch[3]+2,ch[4],ch[0])
          bitmap.draw_text(ch[1]+2,ch[2]+2,ch[3]+2,ch[4],ch[0])
        end
      end
      bitmap.font.color=ch[8] if bitmap.font.color!=ch[8]
      bitmap.draw_text(ch[1]+offset,ch[2]+offset,ch[3],ch[4],ch[0])
    else
      bitmap.font.color=ch[8] if bitmap.font.color!=ch[8]
    end
    if ch[10] # underline
      bitmap.fill_rect(ch[1],ch[2]+ch[4]-4-[(ch[4]-bitmap.font.size)/2,0].max-2,
         ch[3]-2,2,ch[8])
    end
    if ch[11] # strikeout
      bitmap.fill_rect(ch[1],ch[2]+(ch[4]/2)-4,ch[3]-2,2,ch[8])
    end
  end
end

def drawFormattedChars(bitmap,chars)
  return if chars.length==0 || !bitmap||bitmap.disposed?
  oldfont=bitmap.font.clone
  for ch in chars
    drawSingleFormattedChar(bitmap,ch)
  end
  bitmap.font=oldfont
end

# Unused
def drawTextTable(bitmap,x,y,totalWidth,rowHeight,columnWidthPercents,table)
  yPos=y
  for i in 0...table.length
    row=table[i]
    xPos=x
    for j in 0...row.length
      cell=row[j]
      cellwidth=columnWidthPercents[j]*totalWidth/100
      chars=getFormattedText(bitmap,xPos,yPos,cellwidth,-1,cell,rowHeight)
      drawFormattedChars(bitmap,chars)
      xPos+=cellwidth
    end
    yPos+=rowHeight
  end
end

def drawTextEx(bitmap,x,y,width,numlines,text,baseColor,shadowColor)
  normtext=getLineBrokenChunks(bitmap,text,width,nil,true)
  renderLineBrokenChunksWithShadow(bitmap,x,y,normtext,numlines*32,
     baseColor,shadowColor)
end

def drawFormattedTextEx(bitmap,x,y,width,text,baseColor=nil,shadowColor=nil,lineheight=32)
  base=!baseColor ? Color.new(12*8,12*8,12*8) : baseColor.clone
  shadow=!shadowColor ? Color.new(26*8,26*8,25*8) : shadowColor.clone
  text="<c2="+colorToRgb16(base)+colorToRgb16(shadow)+">"+text
  chars=getFormattedText(bitmap,x,y,width,-1,text,lineheight)
  drawFormattedChars(bitmap,chars)
end

# Unused
def pbDrawShadow(bitmap,x,y,width,height,string)
  return if !bitmap || !string
  pbDrawShadowText(bitmap,x,y,width,height,string,nil,bitmap.font.color)
end

def pbDrawShadowText(bitmap,x,y,width,height,string,baseColor,shadowColor=nil,align=0)
  return if !bitmap || !string
  width=(width<0) ? bitmap.text_size(string).width+1 : width
  height=(height<0) ? bitmap.text_size(string).height+1 : height
  y += 4
  if shadowColor && shadowColor.alpha>0
    bitmap.font.color=shadowColor
    bitmap.draw_text(x+2,y,width,height,string,align)
    bitmap.draw_text(x,y+2,width,height,string,align)
    bitmap.draw_text(x+2,y+2,width,height,string,align)
  end
  if baseColor && baseColor.alpha>0
    bitmap.font.color=baseColor
    bitmap.draw_text(x,y,width,height,string,align)
  end
end

def pbDrawOutlineText(bitmap,x,y,width,height,string,baseColor,shadowColor=nil,align=0)
  return if !bitmap || !string
  width=(width<0) ? bitmap.text_size(string).width+4 : width
  height=(height<0) ? bitmap.text_size(string).height+4 : height
  if shadowColor && shadowColor.alpha>0
    bitmap.font.color=shadowColor
    bitmap.draw_text(x-2,y-2,width,height,string,align)
    bitmap.draw_text(x,y-2,width,height,string,align)
    bitmap.draw_text(x+2,y-2,width,height,string,align)
    bitmap.draw_text(x-2,y,width,height,string,align)
    bitmap.draw_text(x+2,y,width,height,string,align)
    bitmap.draw_text(x-2,y+2,width,height,string,align)
    bitmap.draw_text(x,y+2,width,height,string,align)
    bitmap.draw_text(x+2,y+2,width,height,string,align)
  end
  if baseColor && baseColor.alpha>0
    bitmap.font.color=baseColor
    bitmap.draw_text(x,y,width,height,string,align)
  end
end

# Draws text on a bitmap. _textpos_ is an array of text commands. Each text
# command is an array that contains the following:
#  0 - Text to draw
#  1 - X coordinate
#  2 - Y coordinate
#  3 - If true or 1, the text is right aligned. If 2, the text is centered.
#      Otherwise, the text is left aligned.
#  4 - Base color
#  5 - Shadow color
#  6 - If true or 1, the text has an outline. Otherwise, the text has a shadow.
def pbDrawTextPositions(bitmap,textpos)
  for i in textpos
    textsize = bitmap.text_size(i[0])
    x = i[1]
    y = i[2] + 6
    if i[3]==true || i[3]==1   # right align
      x -= textsize.width
    elsif i[3]==2 # centered
      x -= (textsize.width/2)
    end
    if i[6]==true || i[6]==1   # outline text
      pbDrawOutlineText(bitmap,x,y,textsize.width,textsize.height,i[0],i[4],i[5])
    else
      pbDrawShadowText(bitmap,x,y,textsize.width,textsize.height,i[0],i[4],i[5])
    end
  end
end



#===============================================================================
# Draw images on a bitmap
#===============================================================================
def pbCopyBitmap(dstbm,srcbm,x,y,opacity=255)
  rc = Rect.new(0,0,srcbm.width,srcbm.height)
  dstbm.blt(x,y,srcbm,rc,opacity)
end

def pbDrawImagePositions(bitmap,textpos)
  for i in textpos
    srcbitmap=AnimatedBitmap.new(pbBitmapName(i[0]))
    x=i[1]
    y=i[2]
    srcx=i[3] || 0
    srcy=i[4] || 0
    width=(i[5] && i[5]>=0) ? i[5] : srcbitmap.width
    height=(i[6] && i[6]>=0) ? i[6] : srcbitmap.height
    srcrect=Rect.new(srcx,srcy,width,height)
    bitmap.blt(x,y,srcbitmap.bitmap,srcrect)
    srcbitmap.dispose
  end
end
