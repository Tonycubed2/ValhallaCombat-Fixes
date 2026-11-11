Valhalla Combat attack-stamina fix - 2026-10-06
SOURCE PACKAGE: this download contains no compiled DLL.

INSTALL SOURCE AND BUILD
1. Exit Skyrim. Back up C:\dllmaker\valhallaCombat.
2. Extract this ZIP into C:\dllmaker\valhallaCombat, overwriting existing files.
   The three changed source files are:
     src\bin\Hooks.cpp
     src\include\Hooks.h
     src\include\Utils.h
   Preserve your existing CommonLibSSE-NG and vcpkg installations.
3. Open the VS 2022 x64 Native Tools Command Prompt:
     cd /d C:\dllmaker\valhallaCombat
     BUILD_STAMINA_FIX.cmd
   This uses your existing CommonLibSSEPath_NG and VCPKG_ROOT environment variables.
   The script builds Release cleanly in build-stamina-fix with COPY_OUTPUT=OFF.
   It does not copy to the game or change existing mods automatically.
4. Install the generated ValhallaCombat_StaminaFix_DLL.zip as a new MO2 mod,
   below the existing Valhalla mod in the left pane. Keep the original mod
   enabled for its ESP, configuration and other assets. Enable this override.
   Both valhallaCombat.dll and the matching PDB must win file conflicts.
5. In MO2's Data tab inspect SKSE\Plugins\valhallaCombat.dll: its supplying mod
   must be the new override. Check for old copies in the game's physical Data
   directory as well. Restart through MO2's SKSE entry.
6. After reaching the main menu, open ValhallaCombat.log in your SKSE log folder
   (typically Documents\My Games\Skyrim Special Edition\SKSE).
   Search for AVOWNER_RTTI_FIX_20261006. If absent, the new hook build has not
   been confirmed as loaded. Save the DLL_SHA256.txt beside your release files.

WHAT CHANGED
- ActorValueOwner -> Actor now uses skyrim_cast<RE::Actor*> from RE/RTTI.h.
  Skyrim's RTTI adjusts to the real complete Actor object. No guessed subtraction.
- Removed the previous arithmetic round-trip check: subtracting an offset then
  adding it back does not establish that the candidate is a real Actor.
- Valid non-Actor owners fall back to the original stamina function, passing the
  original owner and attack-data pointers unchanged.
- bNonCombatStaminaCost=true uses the original function without converting owner.
- With that setting false, resolved actors outside combat cost zero; actors in
  combat retain the original cost. This preserves the existing intended policy.
- Null owner or attack data returns zero instead of entering engine code with
  missing arguments. RTTI requires a live object; this is not a general repair
  for stale pointers or memory corruption elsewhere.
- Added an identifiable hook installation log marker and runtime version.
- Hook address IDs, call offsets, weapon records and other combat features unchanged.

EVIDENCE AND LIMITS
The 2026-10-06 00:46:16 crash is in getAttackStaminaCost at a virtual dispatch
call [rax+0x720], with Farkas and a Skyforge Steel Greatsword in the context.
That proves the failing path, not the exact input-pointer history or deployed
source revision. The uploaded source already contains an earlier subtraction
fix; without the crashing DLL/disassembly we cannot prove that it was the DLL
actually loaded, nor that this is the only possible cause of this crash.
The greatsword report identifies a useful reproduction case, not a proven bad
weapon record or weapon-specific bug.

CommonLibSSE-NG API reference:
https://ng.commonlib.dev/RTTI_8h_source.html
skyrim_cast forwards source/target RTTI to Skyrim's RTDynamicCast.

VALIDATION COMPLETED HERE
Compiled and ran the exact modified helper and hook bodies in a C++ mock harness
with real multiple inheritance and address/undefined-behavior sanitizers:
- recovered a complete Actor from an offset base subobject;
- rejected a live non-Actor owner and preserved original arguments on fallback;
- outside-combat zero cost and inside-combat original cost;
- enabled noncombat-cost setting bypassed RTTI and actor calls;
- null inputs did not reach the original routine.
Leak detection was disabled because this execution host cannot run LeakSanitizer.
These checks do not validate Skyrim RTTI, native hook ABI or in-game behavior.
No Windows/MSVC/CommonLibSSE build or Skyrim game test was possible here.

REQUIRED IN-GAME TEST BEFORE PUBLISHING
- Confirm the build marker and Skyrim 1.6.1170 in the new log.
- Use a disposable save with a two-handed greatsword. Repeat normal attacks,
  power attacks and bashes outside and inside combat, with the relevant
  noncombat-stamina setting both off and on.
- Include an NPC/follower wielding a greatsword (Farkas if available).
- Repeat leaving Bannered Mare into Whiterun and opening InventoryMenu while
  nearby NPCs continue updating; this matches the supplied crash circumstances.
- Check one-handed weapons too, confirming expected stamina consumption.
- Confirm timed block and other existing features still behave as expected.
- If the same CTD recurs with the marker confirmed, retain the new DLL/PDB,
  new crash log and ValhallaCombat.log. Investigate hook arguments/chaining and
  object lifetime before adding more pointer arithmetic.

ROLLBACK
Disable the new MO2 override to restore the previous files. If installed directly,
restore both backed-up DLL and PDB together. No new-game requirement introduced.
