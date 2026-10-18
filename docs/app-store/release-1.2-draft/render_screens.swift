// Render zoomed App Store layouts at exact pixel size from the 1.1 app captures.
// Usage: swift docs/app-store/release-1.2-draft/render_screens.swift "$PWD/docs/app-store"
import AppKit
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let out = root.appendingPathComponent("release-1.2-draft/screenshots")
try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
// slug, raw capture, crop (x, y, w, h in capture pixels, top-left origin), eyebrow, title, detail, footer, theme
let scenes: [(String,String,CGRect,String,String,String,String,String)] = [
("01-note-to-key","hints",CGRect(x:150,y:620,width:1020,height:1480),"SEE THE NOTE. FIND THE KEY.","Play the note on\nyour real piano.","Musica listens and helps when they're stuck.","20 NOTES A DAY · FREE","mint"),
("02-goal","goal",CGRect(x:105,y:902,width:1113,height:1147),"A LITTLE PRACTICE, EVERY DAY","Small goals.\nBig smiles.","20 free notes a day, with a celebration\nwhen the goal is reached.","BUILD A DAILY HABIT · FREE","peach"),
("03-progress","progress",CGRect(x:0,y:360,width:1320,height:1740),"MUSICA PREMIUM","See their\npractice add up.","Daily scores, gold stars, and the notes\nthey practiced.","PROGRESS CALENDAR · PREMIUM","lavender"),
("04-listens","practice",CGRect(x:0,y:620,width:1320,height:2100),"REAL PIANO. REAL PRACTICE.","Musica listens\nas they play.","No cables. No touchscreen keys.\nAn acoustic or digital piano with speakers.","WORKS WITH YOUR PIANO","mint"),
("05-grand","grand",CGRect(x:180,y:780,width:1140,height:1000),"MUSICA PREMIUM","Treble, bass,\nand grand staff.","Grow from the first notes to\nthe full grand staff.","MORE ROOM TO GROW · PREMIUM","lavender"),
("06-profiles","profiles",CGRect(x:0,y:340,width:1320,height:640),"MUSICA PREMIUM","A profile for\neach child.","Their own pace, goal, and practice history.","MULTIPLE PROFILES · PREMIUM","peach")]
func color(_ hex:String)->NSColor { let n=UInt32(hex,radix:16)!; return NSColor(srgbRed:CGFloat((n>>16)&255)/255,green:CGFloat((n>>8)&255)/255,blue:CGFloat(n&255)/255,alpha:1) }
func text(_ value:String,_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat,_ size:CGFloat,_ weight:NSFont.Weight,_ ink:NSColor,_ align:NSTextAlignment = .left,_ kern:CGFloat = 0,_ spacing:CGFloat = 3) {
 let p=NSMutableParagraphStyle(); p.alignment=align; p.lineBreakMode = .byWordWrapping; p.lineSpacing=spacing
 (value as NSString).draw(in:NSRect(x:x,y:y,width:width,height:height),withAttributes:[.font:NSFont.systemFont(ofSize:size,weight:weight),.foregroundColor:ink,.paragraphStyle:p,.kern:kern])
}
for (slug,raw,crop,eyebrow,title,detail,footer,theme) in scenes {
 let palette = theme == "mint" ? ["dff5eb","247a65","b4e4cf"] : theme == "lavender" ? ["ede8fc","7051b0","d5c7f5"] : ["fff0dd","9d602c","f4d5a6"]
 let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:1320,pixelsHigh:2868,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
 let cg=NSGraphicsContext(bitmapImageRep:bitmap)!.cgContext
 cg.translateBy(x:0,y:2868); cg.scaleBy(x:1,y:-1)
 NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:true)
 color(palette[0]).setFill(); NSRect(x:0,y:0,width:1320,height:2868).fill()
 color(palette[2]).withAlphaComponent(0.65).setFill(); NSBezierPath(ovalIn:NSRect(x:-120,y:1140,width:1560,height:1560)).fill()
 let icon=NSImage(contentsOf:root.appendingPathComponent("../../Musica/Assets.xcassets/AppIcon.appiconset/AppIcon.png"))!
 NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:NSRect(x:90,y:100,width:72,height:72),xRadius:17,yRadius:17).addClip(); icon.draw(in:NSRect(x:90,y:100,width:72,height:72),from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:nil); NSGraphicsContext.restoreGraphicsState()
 text("Musica",182,104,700,70,44,.bold,color("172a38"))
 text(eyebrow,90,222,1140,50,30,.bold,color(palette[1]),.left,4)
 text(title,84,268,1180,380,146,.heavy,color("172a38"),.left,-6,0)
 text(detail,90,652,1140,130,40,.regular,color("3b4b55"))
 // Zoomed card of the real app screen, centered in the space between the copy and the footer.
 let capture=NSImage(contentsOf:root.appendingPathComponent("release-1.1/raw/\(raw).png"))!
 var rect=CGRect(origin:.zero,size:capture.size)
 let source=capture.cgImage(forProposedRect:&rect,context:nil,hints:nil)!.cropping(to:crop)!
 let width:CGFloat=1180, top:CGFloat=820, bottom:CGFloat=2710
 var height=width*crop.height/crop.width
 var cardWidth=width
 if height > bottom-top { height=bottom-top; cardWidth=height*crop.width/crop.height }
 let card=NSRect(x:(1320-cardWidth)/2,y:top+(bottom-top-height)/2,width:cardWidth,height:height)
 NSGraphicsContext.saveGraphicsState()
 let shadow=NSShadow(); shadow.shadowColor=NSColor.black.withAlphaComponent(0.16); shadow.shadowBlurRadius=50; shadow.shadowOffset=NSSize(width:0,height:-18); shadow.set()
 NSColor.white.setFill(); NSBezierPath(roundedRect:card,xRadius:64,yRadius:64).fill()
 NSGraphicsContext.restoreGraphicsState()
 NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:card,xRadius:64,yRadius:64).addClip()
 NSImage(cgImage:source,size:NSSize(width:crop.width,height:crop.height)).draw(in:card,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high.rawValue])
 NSGraphicsContext.restoreGraphicsState()
 text(footer,90,2752,1140,55,28,.bold,color(palette[1]),.center,2.5)
 NSGraphicsContext.restoreGraphicsState()
 try bitmap.representation(using:.jpeg,properties:[.compressionFactor:0.95])!.write(to:out.appendingPathComponent("\(slug).jpg"))
 print("Rendered \(slug)")
}
