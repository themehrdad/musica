// Compose an iPhone App Store search-result mockup: current vs draft screenshots.
// Usage: swift tile_mockup.swift <docs/app-store dir> <output png> <old icon png>
import AppKit
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
let newIcon = NSImage(contentsOf: root.appendingPathComponent("../../Musica/Assets.xcassets/AppIcon.appiconset/AppIcon.png"))!
let oldIcon = NSImage(contentsOfFile: CommandLine.arguments[3])!
let rows: [(String, NSImage, String, String, [String])] = [
 ("Today (1.1)", oldIcon, "Musica: Piano Note Practice", "Sight reading for kids", ["release-1.1/screenshots/01-practice.jpg","release-1.1/screenshots/02-hints.jpg","release-1.1/screenshots/03-goal.jpg"]),
 ("Version 1.2", newIcon, "Note School: Piano Reading", "Treble & bass for kids", ["release-1.2-draft/screenshots/01-note-to-key.jpg","release-1.2-draft/screenshots/02-goal.jpg","release-1.2-draft/screenshots/03-progress.jpg"])]
let s: CGFloat = 3, W: CGFloat = 393*s, rowH: CGFloat = 380*s, H = rowH*CGFloat(rows.count)
let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:Int(W),pixelsHigh:Int(H),bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
let cg = NSGraphicsContext(bitmapImageRep:bitmap)!.cgContext
cg.translateBy(x:0,y:H); cg.scaleBy(x:1,y:-1)
NSGraphicsContext.current = NSGraphicsContext(cgContext:cg,flipped:true)
NSColor.white.setFill(); NSRect(x:0,y:0,width:W,height:H).fill()
func text(_ v:String,_ x:CGFloat,_ y:CGFloat,_ size:CGFloat,_ weight:NSFont.Weight,_ ink:NSColor) {
 (v as NSString).draw(at:NSPoint(x:x*s,y:y*s),withAttributes:[.font:NSFont.systemFont(ofSize:size*s,weight:weight),.foregroundColor:ink])
}
for (i,(label,icon,name,subtitle,shots)) in rows.enumerated() {
 let y0 = CGFloat(i)*380
 cg.saveGState(); cg.translateBy(x:0,y:y0*s)
 text(label.uppercased(),20,10,11,.bold,NSColor.systemPurple)
 let iconRect = NSRect(x:20*s,y:32*s,width:62*s,height:62*s)
 NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:iconRect,xRadius:14*s,yRadius:14*s).addClip(); icon.draw(in:iconRect,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:nil); NSGraphicsContext.restoreGraphicsState()
 text(name,94,38,15,.semibold,.black)
 text(subtitle,94,58,13,.regular,.gray)
 text("★★★★★  no ratings yet",94,76,10,.regular,NSColor.lightGray)
 let get = NSRect(x:305*s,y:48*s,width:68*s,height:28*s)
 NSColor(white:0.94,alpha:1).setFill(); NSBezierPath(roundedRect:get,xRadius:14*s,yRadius:14*s).fill()
 text("Get",326,53,15,.bold,.systemBlue)
 let w: CGFloat = (393-40-16)/3, h = w*2868/1320
 for (j,path) in shots.enumerated() {
  let r = NSRect(x:(20+CGFloat(j)*(w+8))*s,y:108*s,width:w*s,height:h*s)
  NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect:r,xRadius:12*s,yRadius:12*s).addClip()
  NSImage(contentsOf:root.appendingPathComponent(path))!.draw(in:r,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high.rawValue])
  NSGraphicsContext.restoreGraphicsState()
  NSColor(white:0.85,alpha:1).setStroke(); let b = NSBezierPath(roundedRect:r,xRadius:12*s,yRadius:12*s); b.lineWidth = 1; b.stroke()
 }
 cg.restoreGState()
}
try bitmap.representation(using:.png,properties:[:])!.write(to:output)
print("Wrote \(output.path)")
