#****************************************************************************
#**
#**  File     :  /units/XSL0202/XSL0202_script.lua
#**
#**  Summary  :  Seraphim Heavy Bot Script
#**
#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SDFAireauBolterWeapon = import('/lua/seraphimweapons.lua').SDFAireauBolterWeapon02

XSL0202 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFAireauBolterWeapon) {
            SetupTurret = function(self)
                local bp = self:GetBlueprint()
                local yawBone = bp.TurretBoneYaw
                local pitchBone = bp.TurretBonePitch
                local muzzleBone = bp.TurretBoneMuzzle
                local precedence = bp.AimControlPrecedence or 10
                local pitchBone2
                local muzzleBone2
                if bp.TurretBoneDualPitch and bp.TurretBoneDualPitch ~= '' then
                    pitchBone2 = bp.TurretBoneDualPitch
                end
                if bp.TurretBoneDualMuzzle and bp.TurretBoneDualMuzzle ~= '' then
                    muzzleBone2 = bp.TurretBoneDualMuzzle
                end
                if not (self.unit:ValidateBone(yawBone) and self.unit:ValidateBone(pitchBone) and self.unit:ValidateBone(muzzleBone)) then
                    error('*ERROR: Bone aborting turret setup due to bone issues.', 2)
                    return
                elseif pitchBone2 and muzzleBone2 then
                    if not (self.unit:ValidateBone(pitchBone2) and self.unit:ValidateBone(muzzleBone2)) then
                        error('*ERROR: Bone aborting turret setup due to pitch/muzzle bone2 issues.', 2)
                        return
                    end
                end
                if yawBone and pitchBone and muzzleBone then
                    if bp.TurretDualManipulators then
                        self.AimControl = CreateAimController(self, 'Torso', yawBone)
                        self.AimRight = CreateAimController(self, 'Right', pitchBone, pitchBone, muzzleBone)
                        self.AimLeft = CreateAimController(self, 'Left', pitchBone2, pitchBone2, muzzleBone2)
                        self.AimControl:SetPrecedence(precedence)
                        self.AimRight:SetPrecedence(precedence)
                        self.AimLeft:SetPrecedence(precedence)
                        if EntityCategoryContains(categories.STRUCTURE, self.unit) then
                            self.AimControl:SetResetPoseTime(9999999)
                        end
                        self:SetFireControl('Right')
                        self.unit.Trash:Add(self.AimControl)
                        self.unit.Trash:Add(self.AimRight)
                        self.unit.Trash:Add(self.AimLeft)
                    else
                        self.AimControl = CreateAimController(self, 'Default', yawBone, pitchBone, muzzleBone)
                        if EntityCategoryContains(categories.STRUCTURE, self.unit) then
                            self.AimControl:SetResetPoseTime(9999999)
                        end
                        self.unit.Trash:Add(self.AimControl)
                        self.AimControl:SetPrecedence(precedence)
                        if bp.RackSlavedToTurret and table.getn(bp.RackBones) > 0 then
                            for k, v in bp.RackBones do
                                if v.RackBone ~= pitchBone then
                                    local slaver = CreateSlaver(self.unit, v.RackBone, pitchBone)
                                    slaver:SetPrecedence(precedence-1)
                                    self.unit.Trash:Add(slaver)
                                end
                            end
                        end
                    end
                else
                    error('*ERROR: Trying to setup a turreted weapon but there are yaw bones, pitch bones or muzzle bones missing from the blueprint.', 2)
                end


                local numbersexist = true
                local turretyawmin, turretyawmax, turretyawspeed
                local turretpitchmin, turretpitchmax, turretpitchspeed

                -- SETUP MANIPULATORS AND SET TURRET YAW, PITCH AND SPEED
                if self:GetBlueprint().TurretYaw and self:GetBlueprint().TurretYawRange then
                    turretyawmin, turretyawmax = self:GetTurretYawMinMax()
                else
                    numbersexist = false
                end
                if self:GetBlueprint().TurretYawSpeed then
                    turretyawspeed = self:GetTurretYawSpeed()
                else
                    numbersexist = false
                end
                if self:GetBlueprint().TurretPitch and self:GetBlueprint().TurretPitchRange then
                    turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
                else
                    numbersexist = false
                end
                if self:GetBlueprint().TurretPitchSpeed then
                    turretpitchspeed = self:GetTurretPitchSpeed()
                else
                    numbersexist = false
                end
                if numbersexist then
                    self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                    if self.AimRight then
                        self.AimRight:SetFiringArc(turretyawmin/6, turretyawmax/6, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                    end
                    if self.AimLeft then
                        self.AimLeft:SetFiringArc(turretyawmin/6, turretyawmax/6, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
                    end
                else
                    local strg = '*ERROR: TRYING TO SETUP A TURRET WITHOUT ALL TURRET NUMBERS IN BLUEPRINT, ABORTING TURRET SETUP. WEAPON: ' .. self:GetBlueprint().Label .. ' UNIT: '.. self.unit:GetUnitId()
                    error(strg, 2)
                end
            end,
        }
    },
}
TypeClass = XSL0202