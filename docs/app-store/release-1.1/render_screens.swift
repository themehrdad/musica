// Render code-native App Store layouts at exact pixel size using original app captures.
import AppKit
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let scenes: [(String,String,String,String,String,String,String)] = [
("01-practice","practice","REAL PIANO. REAL PRACTICE.","Play the note\non your piano.","Musica listens as your child plays.\nNo cables. No touchscreen keys.","20 NOTES A DAY · FREE","mint"),
("02-hints","hints","FROM THE STAFF TO THE KEYS","A little help.\nA lot of progress.","Helpful note names and keyboard hints\nwhen they need a nudge.","LEARN AT THEIR OWN PACE","lavender"),
("03-goal","goal","A LITTLE PRACTICE, EVERY DAY","Small goals.\nBig smiles.","20 free notes each day.\nA celebration when the goal is reached.","BUILD A DAILY HABIT","peach"),
("04-progress","progress","MUSICA PREMIUM","See their\npractice add up.","Daily scores, gold stars, and a record\nof the notes they practiced.","PROGRESS CALENDAR · PREMIUM","lavender"),
("05-grand","grand","MUSICA PREMIUM","Ready for\nthe next staff.","Grow from treble to bass\nand the full grand staff.","MORE ROOM TO GROW · PREMIUM","mint"),
("06-profiles","profiles","MUSICA PREMIUM","Their own\nspace to learn.","A profile, pace, and practice history\nfor each child in your family.","MULTIPLE PROFILES · PREMIUM","peach")]
func color(_ hex:String)->NSColor { let n=UInt32(hex,radix:16)!; return NSColor(srgbRed:CGFloat((n>>16)&255)/255,green:CGFloat((n>>8)&255)/255,blue:CGFloat(n&255)/255,alpha:1) }
func text(_ value:String,_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat,_ size:CGFloat,_ weight:NSFont.Weight,_ ink:NSColor,_ align:NSTextAlignment = .left,_ kern:CGFloat = 0) {
 let p=NSMutableParagraphStyle(); p.alignment=align; p.lineBreakMode = .byWordWrapping; p.lineSpacing=3
 (value as NSString).draw(in:NSRect(x:x,y:y,width:width,height:height),withAttributes:[.font:NSFont.systemFont(ofSize:size,weight:weight),.foregroundColor:ink,.paragraphStyle:p,.kern:kern])
}
for (slug,raw,eyebrow,title,detail,footer,theme) in scenes {
 let palette = theme == "mint" ? ["dff5eb","247a65","b4e4cf"] : theme == "lavender" ? ["ede8fc","7051b0","d5c7f5"] : ["fff0dd","9d602c","f4d5a6"]
 let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:1320,pixelsHigh:2868,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
 let context=NSGraphicsContext(bitmapImageRep:bitmap)!
 let cg=context.cgContext
 cg.translateBy(x:0,y:2868); cg.scaleBy(x:1,y:-1)
 NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:true)
 color(palette[0]).setFill(); NSRect(x:0,y:0,width:1320,height:2868).fill()
 color(palette[2]).withAlphaComponent(0.65).setFill(); NSBezierPath(ovalIn:NSRect(x:-120,y:1040,width:1560,height:1560)).fill()
 let icon=NSImage(contentsOf:root.appendingPathComponent("../../../Musica/Assets.xcassets/AppIcon.appiconset/AppIcon.png"))!
 NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:NSRect(x:100,y:106,width:68,height:68),xRadius:16,yRadius:16).addClip(); icon.draw(in:NSRect(x:100,y:106,width:68,height:68),from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:nil); NSGraphicsContext.restoreGraphicsState()
 text("Musica",188,109,700,70,42,.bold,color("172a38"))
 text(eyebrow,100,242,1120,50,27,.bold,color(palette[1]),.left,4)
 text(title,94,303,1140,286,116,.heavy,color("172a38"),.left,-5)
 text(detail,100,592,1120,145,38,.regular,color("3b4b55"))
 let phone=NSRect(x:220,y:815,width:880,height:1882)
 color("23313c").setFill(); NSBezierPath(roundedRect:phone,xRadius:106,yRadius:106).fill()
 let image=NSImage(contentsOf:root.appendingPathComponent("raw/\(raw).png"))!
 let frame=NSRect(x:233,y:828,width:854,height:1855.4)
 NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:frame,xRadius:93,yRadius:93).addClip(); image.draw(in:frame,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high.rawValue]); NSGraphicsContext.restoreGraphicsState()
 text(footer,100,2750,1120,55,26,.bold,color(palette[1]),.center,2.5)
 NSGraphicsContext.restoreGraphicsState()
 try bitmap.representation(using:.png,properties:[:])!.write(to:root.appendingPathComponent("screenshots/\(slug).png"))
 try bitmap.representation(using:.jpeg,properties:[.compressionFactor:0.95])!.write(to:root.appendingPathComponent("screenshots/\(slug).jpg"))
 print("Rendered \(slug)")
}
