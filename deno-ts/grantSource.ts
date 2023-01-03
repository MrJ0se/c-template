import { C } from './deps.ts';

export async function grantSource(CurrentVersion:string):Promise<string> {
	return await C.grantFileTree(
		new URL('..', import.meta.url),
		(await import("./map.ts")).map,
		`cache/ctemplate-${CurrentVersion}`
	)
}