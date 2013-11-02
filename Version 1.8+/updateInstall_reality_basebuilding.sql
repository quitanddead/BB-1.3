--
-- Creates a temporary table
--
CREATE TABLE IF NOT EXISTS `instance_deployable_old` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(60) NOT NULL,
  `deployable_id` smallint(5) unsigned NOT NULL,
  `owner_id` int(10) unsigned NOT NULL,
  `instance_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `worldspace` varchar(60) NOT NULL DEFAULT '[0,[0,0,0]]',
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Hitpoints` varchar(500) NOT NULL DEFAULT '[]',
  `Fuel` double(13,0) NOT NULL DEFAULT '0',
  `Damage` double(13,0) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx1_instance_deployable_old` (`deployable_id`),
  KEY `idx2_instance_deployable_old` (`owner_id`),
  KEY `idx3_instance_deployable_old` (`instance_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT AUTO_INCREMENT=6 ;

--
-- Copies all data to the new table from the existing one
--
INSERT INTO instance_deployable_old
SELECT *
FROM instance_deployable;

--
-- Removes the Base Building 1.2 items from the original table
--
DELETE FROM instance_deployable
WHERE deployable_id >= 6 and deployable_id <= 52;

--
-- Copies Base Building items from the new table, to the original with the new array system
--
insert INTO instance_deployable
  (id, unique_id,  deployable_id, owner_id, instance_id, worldspace, inventory, last_updated,
  created, Hitpoints, Fuel, Damage)
  
  select   instance_deployable_old.id, instance_deployable_old.unique_id,  deployable_id, owner_id, instance_id, instance_deployable_old.worldspace, CONCAT("[[""", instance_deployable_old.unique_id, """],[""", survivor.unique_id, """]]" ), instance_deployable_old.last_updated,
  created, Hitpoints, Fuel, Damage from instance_deployable_old
    inner join survivor on instance_deployable_old.owner_id = survivor.id
WHERE deployable_id >= 6 and deployable_id <= 52;

--
-- Deletes the temporary table
--
DROP TABLE instance_deployable_old;

--
-- Adds New BB Objects to Database
--
INSERT INTO `deployable` (`class_name`) VALUES
('Land_sara_hasic_zbroj'),
('Land_Shed_wooden'),
('Land_Barrack2'),
('Land_vez'),
('FlagCarrierBIS_EP1'),
('Land_A_Minaret_Porto_EP1'),
('Land_Ind_Shed_01_main'),
('Land_Fire_barrel'),
('Land_WoodenRamp'),
('Land_House_C_4_EP1'),
('Land_House_C_11_EP1'),
('Land_House_K_6_EP1'),
('Land_House_K_7_EP1'),
('Land_House_C_9_EP1'),
('Land_House_C_10_EP1'),
('Land_House_C_12_EP1'),
('Land_House_C_5_V3_EP1'),
('Land_House_C_3_EP1'),
('Land_House_L_4_EP1'),
('Land_House_L_6_EP1'),
('Land_House_L_7_EP1'),
('Land_House_L_8_EP1'),
('Land_House_L_1_EP1'),
('Land_House_C_5_EP1'),
('Land_House_C_2_EP1'),
('Land_ConcreteRamp'),
('RampConcrete'),
('HeliH'),
('HeliHCivil'),
('Land_Campfire'),
('Land_ladder'),
('Land_ladder_half'),
('Land_Misc_Scaffolding'),
('Land_Ind_TankSmall2_EP1'),
('PowerGenerator_EP1'),
('Land_Ind_IlluminantTower'),
('Land_A_Castle_Bergfrit'),
('Land_A_Castle_Stairs_A');