import * as path from "https://deno.land/std@0.154.0/path/mod.ts"

function relativePath(x:string) {
	return path.fromFileUrl(new URL(x, import.meta.url)).replace(/^[\\\/]([A-Z]:[\\\/])/g, (_,b)=>b)
}

//exclude these paths
function arrayIfExist(xrelative:string, func:(data:string)=>string[] ):string[] {
	try {
		const data = Deno.readFileSync(relativePath(xrelative))
		return func(new TextDecoder().decode(data));
	} catch(_) {
		return [];
	}

}
const filter = [
	...arrayIfExist('../.vscode/settings.json', (data)=>{
		return JSON.parse(data)['deno.enablePaths']
	}),
	...arrayIfExist('../.gitignore', (data)=>{
		return data.replaceAll('\r\n','\n').split('\n').map((x)=>{
			x = x.trim();
			if (x.startsWith('\\')||x.startsWith('/'))
				x = x.substring(1);
			return x;
		}).filter((x)=>x!=""&&!x.startsWith('#'))
	}),
	".vscode",
	".git",
	".gitattributes",
	".gitignore"
];

const files = [] as string[];

function testFilter(path:string, filter:string):boolean {
	if (path == filter) return true;
	if (path.endsWith(filter)) {
		const fch = path.charAt(path.length - filter.length - 1);
		if (fch == '\\' || fch == '/') return true;
	}
	if (filter.startsWith('*') && path.endsWith(filter.substring(1)))
		return true;
	return false;
}

function findFiles(folder:string, root:string) {
	Array.from(Deno.readDirSync(folder)).forEach((d)=>{
		const fullPath = path.resolve(folder, d.name);
		const relPath = path.relative(root, fullPath);

		if (filter.find((x)=>testFilter(relPath, x)) != undefined) return;
		if (d.isDirectory) return findFiles(fullPath, root);
		files.push(relPath);
	});
}
const root = relativePath('..');
findFiles(root, root);

const mapts = 'export const map = '+JSON.stringify(files);
const maptsPath = (relativePath('./map.ts'));

try {
	const r = Deno.statSync(maptsPath)
	if (r != undefined && r.isFile) {
		const txtold = (new TextDecoder().decode(Deno.readFileSync(maptsPath)));
		if (txtold == mapts)
			Deno.exit(0);
	}
	//deno-lint-ignore no-empty
} catch (_) {}

Deno.writeFileSync(maptsPath, new TextEncoder().encode(mapts));
console.log("map.ts updated");
Deno.exit(100);