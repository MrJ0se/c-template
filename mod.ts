import { C, Util } from './deno-ts/deps.ts';
import { grantSource } from './deno-ts/grantSource.ts';

export interface Options {
	shared_lib:boolean,
	static_lib:boolean,
}

const CurrentVersion = '0.0.1';
export async function mainCurrent (cmakeOpts:C.CMakeCrossOps, btype:C.BuildType, opts:Options):Promise<C.LibraryMeta[]> {
	const bsuffix = C.postfixFromBuildType(btype);

	const proot = C.projectRoot(`ctemplate-${CurrentVersion}`);
	const srcRoot = await grantSource(CurrentVersion);
	const buildRoot = proot(C.Scope.TARGET, `build${bsuffix}`);
	const binInc = C.path.resolve(srcRoot, 'include');

	//build
	await C.kv(C.Scope.TARGET).markProgressAsync(`ctemplate-${CurrentVersion}-build${bsuffix}`, async ()=> {
		C.AFS.mkdir(buildRoot);
		const args = [
			'-B', buildRoot,
			'-S', srcRoot,
			'rebuild', C.cmakeFlagFromBuildType(btype),
			'-DCTemplate_STATIC='+opts.static_lib?'ON':'OFF','-DCTemplate_SHARED='+opts.shared_lib?'ON':'OFF'
		];
		if (!(await C.CMake(args, cmakeOpts)).success)
			throw C.exitError("failed");
	});
	
	const template = {
		pa:C.curTarget,
		name:`CTemplate`,
		version: CurrentVersion,
		debug:btype != C.BuildType.RELEASE_FAST,
		inc:[binInc],
	};

	const lib_sta:string[] = [];
	const lib_dyn:string[] = [];

	C.AFS.search(buildRoot, (path:string, isFile:boolean)=>{
		if (!isFile) return true;
		switch (C.path.extname(path)) {
		case '.lib':
			if (C.path.basename(path).indexOf('static') < 0) {
				lib_dyn.push(path);
				break;
			}
			/*falls through*/
		case '.a':
			lib_sta.push(path);
			break;
		case '.dylib':
		case '.so':
		case '.dll':
			lib_dyn.push(path);
			break;
		}
		return true;
	});

	const r:C.LibraryMeta[] = [];

	if (lib_sta.length > 0)
		r.push(new C.LibraryMeta(Util.deepClone(template, {bin:lib_sta})));
	if (lib_dyn.length > 0)
		r.push(new C.LibraryMeta(Util.deepClone(template, {bin:lib_dyn})));

	return r;
}