package;

import sys.FileSystem;
import sys.io.Process;
using haxe.io.Path;
using StringTools;

class Main {
    
    static var HDLL_LIBRARIES : Array<String> = [
        "fmt",
        "ssl",
        "openal",
        "uv",
        "ui",
        "sqlite",
        "sdl"
    ];
    
    static var EXCLUDED_DYLIBS : Array<String> = [
        "libSystem",
        "libz",
        "/System/Library",
        "Framework",
        "/usr/lib/",
        "@executable_path/"
    ];
    
    static function isExcluded(lib:String) {
        if (lib.indexOf('.dylib') == -1)
            return true;
        for (el in EXCLUDED_DYLIBS) {
            if (lib.indexOf(el) != -1) {
                return true;
            }
        }
        return false;
    }
    
    static inline function runProcess(cmd:String, args:Array<String>) {
        trace('running process: $cmd ${args.join(" ")}');
        return new Process(cmd, args);
    }

    static inline function runProcessAndCheckError(cmd:String, args:Array<String>) {
        var p = runProcess(cmd, args);
        var perr = p.stderr.readAll().toString();
        if (perr != null && perr != '') {
            trace('${cmd}.ERROR: ${perr}');
        }
        p.close();
    }
    
    static public function main() {
        var executablePath = Sys.args()[0];
        if (executablePath == null)
            Sys.exit(1);
        
        trace('executablePath: $executablePath');
        if (!executablePath.endsWith('/')) {
            executablePath += '/';
        }
        var librariesRelativeToExec = '$executablePath';
        var p, pout, perr, depString, libPath, deps, depPath, depFile;
        var regex = ~/.+?(?=dylib)/;
        for (lib in HDLL_LIBRARIES) {
            libPath = '$librariesRelativeToExec${lib}.hdll';
            if (!FileSystem.exists(libPath))
                continue;
            
            p = runProcess('otool', ['-L', libPath]);
            pout = p.stdout.readAll();
            p.close();
            deps = pout.toString().split('\n');
            for (d in deps) {
                if (isExcluded(d))
                    continue;
                
                depString = d.toString().trim();
                if (regex.match(depString)) {
                    depPath = new Path(regex.matched(0) + 'dylib');
                } else {
                    trace('$depString not matched with the RegExp');
                    continue;
                }

                depFile = '${depPath.file}.${depPath.ext}';
                runProcessAndCheckError('cp', [depPath.toString(), '$librariesRelativeToExec$depFile']);
                runProcessAndCheckError('install_name_tool', ['-change', '${depPath.toString()}', '@executable_path/$depFile', '$libPath']);
            }
        }
	}
}
