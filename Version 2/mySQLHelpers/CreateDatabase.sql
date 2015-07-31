SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `Recognition_Tunneling_L_20` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `Recognition_Tunneling_L_20` ;

-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Experiments`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Experiments` (
  `Experiment_Index` INT NOT NULL AUTO_INCREMENT ,
  `Experiment_Name` VARCHAR(25) NOT NULL ,
  `Experiment_Date` DATE NOT NULL ,
  `Experiment_Comments` TEXT NOT NULL ,
  PRIMARY KEY (`Experiment_Index`) ,
  UNIQUE INDEX `ExperimentIndex_UNIQUE` (`Experiment_Index` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Analytes`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Analytes` (
  `Analyte_Index` INT NOT NULL AUTO_INCREMENT ,
  `Analyte_Experiment_Index` INT NOT NULL, 
  `Analyte_Name` VARCHAR(75) NOT NULL ,
  `Ana_num_Experiment_Samples` BIGINT NOT NULL DEFAULT 0 ,
  `Ana_num_Control_Samples` BIGINT NOT NULL DEFAULT 0 ,
  `Ana_numPeaks` BIGINT NOT NULL DEFAULT -1 ,
  `Ana_percentWaterPeaks` double NOT NULL DEFAULT 0 ,
  `Ana_numClusters` BIGINT NOT NULL DEFAULT -1 ,
  PRIMARY KEY (`Analyte_Index`) ,
  UNIQUE INDEX `AnalyteIndex_UNIQUE` (`Analyte_Index` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Folders`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Folders` (
  `Folder_Index` INT NOT NULL AUTO_INCREMENT ,
  `Folder` VARCHAR(400) NOT NULL ,
  `Fold_number_Samples` BIGINT NOT NULL DEFAULT -1 ,
  `Fold_numPeaks` BIGINT NOT NULL DEFAULT -1 ,
  `Fold_numWaterPeaks` BIGINT NOT NULL DEFAULT -1 ,
  `Fold_numClusters` BIGINT NOT NULL DEFAULT -1 ,
  `Fold_avgBaselineVariance` double NOT NULL DEFAULT -1 ,
  PRIMARY KEY (`Folder_Index`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Files`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Files` (
  `File_Index` INT NOT NULL AUTO_INCREMENT ,
  `Folder_Index` INT NOT NULL DEFAULT -1 ,
  `FileName` VARCHAR(400) NOT NULL ,
  `Fl_numSamples` BIGINT NOT NULL DEFAULT -1 ,
  `Fl_numPeaks` BIGINT NOT NULL DEFAULT -1 ,
  `Fl_numWaterPeaks` BIGINT NOT NULL DEFAULT -1 ,
  `Fl_numClusters` BIGINT NOT NULL DEFAULT -1 ,
  `Fl_BaselineVariance` double NOT NULL DEFAULT -1 ,
  `Fl_60Hz` double NOT NULL DEFAULT -1 ,
  INDEX `fk_File_Folders1_idx` (`Folder_Index` ASC) ,
  PRIMARY KEY (`File_Index`) ,
  CONSTRAINT `fk_File_Folders1`
    FOREIGN KEY (`Folder_Index` )
    REFERENCES `Recognition_Tunneling_L_20`.`Folders` (`Folder_Index` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Clusters`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Clusters` (
  `Cluster_Index` BIGINT NOT NULL AUTO_INCREMENT,
  `Folder_Index` INT NOT NULL DEFAULT -1 ,
  `File_Index` INT NOT NULL DEFAULT -1 ,
  `C_startIndex` BIGINT NOT NULL DEFAULT 0 ,
  `C_endIndex` BIGINT NOT NULL DEFAULT 0 ,
  `C_SVM_Rating` INT NOT NULL DEFAULT -1 ,
  PRIMARY KEY (`Cluster_Index`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Peaks`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Peaks` (
  `Peak_Index` BIGINT NOT NULL AUTO_INCREMENT,
  `Cluster_Index` INT NOT NULL DEFAULT -1 ,
  `Folder_Index` INT NOT NULL DEFAULT -1 ,
  `File_Index` INT NOT NULL DEFAULT -1 ,
  `P_SVM_Rating` INT NOT NULL DEFAULT -1 ,
  `P_startIndex` BIGINT NOT NULL DEFAULT -1 ,
  `P_endIndex` BIGINT NOT NULL DEFAULT -1 ,
  `P_identity` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`Peak_Index`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`Experiment_Analytes`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`Experiment_Analytes` (
  `Experiment_Index` INT NOT NULL DEFAULT -1 ,
  `Analyte_Index` INT NOT NULL DEFAULT -1 ,
  `EA_Role` VARCHAR(45) NOT NULL )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`AnalyteFolders`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`AnalyteFolders` (
  `index` INT NOT NULL AUTO_INCREMENT ,
  `Analyte_Index` INT ZEROFILL NOT NULL ,
  `Folder_Index` INT ZEROFILL NOT NULL ,
  `Control` INT ZEROFILL NOT NULL ,
  PRIMARY KEY (`index`) )
ENGINE = InnoDB;

USE `Recognition_Tunneling_L_20` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


ALTER TABLE experiments 
ADD maxSVMPoints int not null default 0,
ADD Keep_Ordered bool  not null default false,
ADD Calc_Accuracy_Spreads bool not null default false,
ADD Plot_Options bool not null default false,
ADD Show_Clusters bool not null default false,
ADD Show_Peaks bool not null default false,
ADD Default_Plots bool not null default false,
ADD Show_60hz_Noise bool not null default false,
ADD param_plots_2D bool not null default false,
ADD param_plots_3D bool not null default false,
ADD Remove_Water bool not null default false,
ADD Remove_Common_Peaks bool not null default false,
ADD Remove_Anomaly bool not null default false,
ADD Check_Simularity bool not null default false,
ADD Number_SVM_Iterations int not null default false,
ADD Do_PCA bool not null default false,
ADD percentWater float not null default 0;

ALTER TABLE folders
ADD baseline_Threshold double  not null default 0,
ADD num_ClusterFFT_coef int  not null default 0,
ADD num_peakFFT_coef int  not null default 0,
ADD minimum_Width int  not null default 0,
ADD clusterSize int not null default 0,
ADD minimum_FFT_Size int not null default 0,
ADD lowPass_Freq double not null default 0,
ADD minimum_cluster_FFT_Size int not null default 0;

ALTER TABLE analytes
ADD baseline_Threshold double  not null default 0,
ADD num_ClusterFFT_coef int  not null default 0,
ADD num_peakFFT_coef int  not null default 0,
ADD minimum_Width int  not null default 0,
ADD clusterSize int not null default 0,
ADD minimum_FFT_Size int not null default 0,
ADD lowPass_Freq double not null default 0,
ADD minimum_cluster_FFT_Size int not null default 0;

ALTER TABLE clusters 
ADD C_peaksInCluster double NOT NULL DEFAULT 0,
ADD C_frequency double NOT NULL DEFAULT 0,
ADD C_averageAmplitude double NOT NULL DEFAULT 0,
ADD C_topAverage double NOT NULL DEFAULT 0,
ADD C_clusterWidth double NOT NULL DEFAULT 0,
ADD C_roughness double NOT NULL DEFAULT 0,
ADD C_maxAmplitude double NOT NULL DEFAULT 0,
ADD C_totalPower double NOT NULL DEFAULT 0,
ADD C_iFFTLow double NOT NULL DEFAULT 0,
ADD C_iFFTMedium double NOT NULL DEFAULT 0,
ADD C_iFFTHigh double NOT NULL DEFAULT 0,
ADD C_clusterFFT1 double NOT NULL DEFAULT 0,
ADD C_clusterFFT2 double NOT NULL DEFAULT 0,
ADD C_clusterFFT3 double NOT NULL DEFAULT 0,
ADD C_clusterFFT4 double NOT NULL DEFAULT 0,
ADD C_clusterFFT5 double NOT NULL DEFAULT 0,
ADD C_clusterFFT6 double NOT NULL DEFAULT 0,
ADD C_clusterFFT7 double NOT NULL DEFAULT 0,ADD C_clusterFFT8 double NOT NULL DEFAULT 0,ADD C_clusterFFT9 double NOT NULL DEFAULT 0,ADD C_clusterFFT10 double NOT NULL DEFAULT 0,ADD C_clusterFFT11 double NOT NULL DEFAULT 0,ADD C_clusterFFT12 double NOT NULL DEFAULT 0,ADD C_clusterFFT13 double NOT NULL DEFAULT 0,ADD C_clusterFFT14 double NOT NULL DEFAULT 0,ADD C_clusterFFT15 double NOT NULL DEFAULT 0,ADD C_clusterFFT16 double NOT NULL DEFAULT 0,ADD C_clusterFFT17 double NOT NULL DEFAULT 0,ADD C_clusterFFT18 double NOT NULL DEFAULT 0,ADD C_clusterFFT19 double NOT NULL DEFAULT 0,ADD C_clusterFFT20 double NOT NULL DEFAULT 0,ADD C_clusterFFT21 double NOT NULL DEFAULT 0,ADD C_clusterFFT22 double NOT NULL DEFAULT 0,ADD C_clusterFFT23 double NOT NULL DEFAULT 0,ADD C_clusterFFT24 double NOT NULL DEFAULT 0,ADD C_clusterFFT25 double NOT NULL DEFAULT 0,ADD C_clusterFFT26 double NOT NULL DEFAULT 0,ADD C_clusterFFT27 double NOT NULL DEFAULT 0,ADD C_clusterFFT28 double NOT NULL DEFAULT 0,ADD C_clusterFFT29 double NOT NULL DEFAULT 0,ADD C_clusterFFT30 double NOT NULL DEFAULT 0,ADD C_clusterFFT31 double NOT NULL DEFAULT 0,ADD C_clusterFFT32 double NOT NULL DEFAULT 0,ADD C_clusterFFT33 double NOT NULL DEFAULT 0,ADD C_clusterFFT34 double NOT NULL DEFAULT 0,ADD C_clusterFFT35 double NOT NULL DEFAULT 0,ADD C_clusterFFT36 double NOT NULL DEFAULT 0,ADD C_clusterFFT37 double NOT NULL DEFAULT 0,ADD C_clusterFFT38 double NOT NULL DEFAULT 0,ADD C_clusterFFT39 double NOT NULL DEFAULT 0,ADD C_clusterFFT40 double NOT NULL DEFAULT 0,ADD C_clusterFFT41 double NOT NULL DEFAULT 0,ADD C_clusterFFT42 double NOT NULL DEFAULT 0,ADD C_clusterFFT43 double NOT NULL DEFAULT 0,ADD C_clusterFFT44 double NOT NULL DEFAULT 0,ADD C_clusterFFT45 double NOT NULL DEFAULT 0,ADD C_clusterFFT46 double NOT NULL DEFAULT 0,ADD C_clusterFFT47 double NOT NULL DEFAULT 0,ADD C_clusterFFT48 double NOT NULL DEFAULT 0,ADD C_clusterFFT49 double NOT NULL DEFAULT 0,ADD C_clusterFFT50 double NOT NULL DEFAULT 0,ADD C_clusterFFT51 double NOT NULL DEFAULT 0,ADD C_clusterFFT52 double NOT NULL DEFAULT 0,ADD C_clusterFFT53 double NOT NULL DEFAULT 0,ADD C_clusterFFT54 double NOT NULL DEFAULT 0,ADD C_clusterFFT55 double NOT NULL DEFAULT 0,ADD C_clusterFFT56 double NOT NULL DEFAULT 0,ADD C_clusterFFT57 double NOT NULL DEFAULT 0,ADD C_clusterFFT58 double NOT NULL DEFAULT 0,ADD C_clusterFFT59 double NOT NULL DEFAULT 0,ADD C_clusterFFT60 double NOT NULL DEFAULT 0,
ADD C_clusterFFT61 double NOT NULL DEFAULT 0,
ADD C_highLow double NOT NULL DEFAULT 0,
ADD C_freq_Maximum_Peaks1 double NOT NULL DEFAULT 0,
ADD C_freq_Maximum_Peaks2 double NOT NULL DEFAULT 0,
ADD C_freq_Maximum_Peaks3 double NOT NULL DEFAULT 0,
ADD C_freq_Maximum_Peaks4 double NOT NULL DEFAULT 0,
ADD C_clusterCepstrum1 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum2 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum3 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum4 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum5 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum6 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum7 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum8 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum9 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum10 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum11 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum12 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum13 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum14 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum15 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum16 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum17 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum18 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum19 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum20 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum21 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum22 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum23 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum24 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum25 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum26 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum27 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum28 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum29 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum30 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum31 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum32 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum33 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum34 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum35 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum36 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum37 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum38 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum39 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum40 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum41 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum42 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum43 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum44 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum45 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum46 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum47 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum48 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum49 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum50 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum51 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum52 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum53 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum54 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum55 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum56 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum57 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum58 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum59 double NOT NULL DEFAULT 0,ADD C_clusterCepstrum60 double NOT NULL DEFAULT 0,
ADD C_clusterCepstrum61 double  NOT NULL DEFAULT 0,
ADD C_clusterFFT_Whole1 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole2 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole3 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole4 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole5 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole6 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole7 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole8 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole9 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole10 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole11 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole12 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole13 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole14 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole15 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole16 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole17 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole18 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole19 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole20 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole21 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole22 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole23 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole24 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole25 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole26 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole27 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole28 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole29 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole30 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole31 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole32 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole33 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole34 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole35 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole36 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole37 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole38 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole39 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole40 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole41 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole42 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole43 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole44 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole45 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole46 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole47 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole48 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole49 double NOT NULL DEFAULT 0,ADD C_clusterFFT_Whole50 double NOT NULL DEFAULT 0,
ADD C_clusterFFT_Whole51 double NOT NULL DEFAULT 0,
ADD C_clusterFFT_TotalPowerW double NOT NULL DEFAULT 0,
ADD C_clusterFFT_maxFreq double NOT NULL DEFAULT 0,
ADD C_clusterFFT_tilt double NOT NULL DEFAULT 0,
ADD C_clusterFFT_misMatch double NOT NULL DEFAULT 0,
ADD C_clusterFFT_Halfs double NOT NULL DEFAULT 0,
ADD C_clusterFFT_Third double NOT NULL DEFAULT 0,
ADD C_Reserved1 double NOT NULL DEFAULT 0,
ADD C_Reserved2 double NOT NULL DEFAULT 0,
ADD C_Reserved3 double NOT NULL DEFAULT 0,
ADD C_Reserved4 double NOT NULL DEFAULT 0;

ALTER TABLE peaks
ADD P_maxAmplitude double NOT NULL DEFAULT 0,
ADD P_averageAmplitude double NOT NULL DEFAULT 0,
ADD P_topAverage double NOT NULL DEFAULT 0,
ADD P_peakWidth double NOT NULL DEFAULT 0,
ADD P_roughness double NOT NULL DEFAULT 0,
ADD P_totalPower double NOT NULL DEFAULT 0,
ADD P_iFFTLow double NOT NULL DEFAULT 0,
ADD P_iFFTMedium double NOT NULL DEFAULT 0,
ADD P_iFFTHigh double NOT NULL DEFAULT 0,
ADD P_frequency double NOT NULL DEFAULT 0,
ADD P_peakFFT1 double NOT NULL DEFAULT 0,ADD P_peakFFT2 double NOT NULL DEFAULT 0,ADD P_peakFFT3 double NOT NULL DEFAULT 0,ADD P_peakFFT4 double NOT NULL DEFAULT 0,ADD P_peakFFT5 double NOT NULL DEFAULT 0,ADD P_peakFFT6 double NOT NULL DEFAULT 0,ADD P_peakFFT7 double NOT NULL DEFAULT 0,ADD P_peakFFT8 double NOT NULL DEFAULT 0,ADD P_peakFFT9 double NOT NULL DEFAULT 0,
ADD P_peakFFT10 double NOT NULL DEFAULT 0,
ADD P_highLow_Ratio double NOT NULL DEFAULT 0,
ADD P_Odd_FFT double NOT NULL DEFAULT 0,
ADD P_Even_FFT double NOT NULL DEFAULT 0,
ADD P_OddEvenRatio double  NOT NULL DEFAULT 0,
ADD P_peakFFT_Whole1 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole2 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole3 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole4 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole5 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole6 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole7 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole8 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole9 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole10 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole11 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole12 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole13 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole14 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole15 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole16 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole17 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole18 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole19 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole20 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole21 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole22 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole23 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole24 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole25 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole26 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole27 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole28 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole29 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole30 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole31 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole32 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole33 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole34 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole35 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole36 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole37 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole38 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole39 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole40 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole41 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole42 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole43 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole44 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole45 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole46 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole47 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole48 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole49 double NOT NULL DEFAULT 0,ADD P_peakFFT_Whole50 double NOT NULL DEFAULT 0,
ADD P_peakFFT_Whole51 double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_TotalPowerW double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_maxFreq double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_misMatch double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_tilt double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_Halfs double NOT NULL DEFAULT 0,
ADD P_peakFFTWhole_Third double NOT NULL DEFAULT 0,
ADD P_Reserved1 double NOT NULL DEFAULT 0,
ADD P_Reserved2 double NOT NULL DEFAULT 0,
ADD P_Reserved3 double NOT NULL DEFAULT 0,
ADD P_Reserved4 double NOT NULL DEFAULT 0;


-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`SVM_Parameters`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`SVM_Parameters` (
  `SVM_Experiment_Index` INT NOT NULL DEFAULT -1 ,
  `SVM_role` varchar(45) NOT NULL,
  `SVM_xsup` TEXT NOT NULL,
  `SVM_alpha` TEXT NOT NULL,
  `SVM_rho` double NOT NULL DEFAULT 0,
  `SVM_kernal` varchar(45) NOT NULL,
  `SVM_kernaloption` varchar(45) NOT NULL,
  `SVM_threshold` double NOT NULL DEFAULT 0,
  `SVM_colNames` TEXT NOT NULL
 )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`SVM_Results`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`SVM_Results` (
  `SVM_R_ParameterSet_Index` INT NOT NULL  AUTO_INCREMENT ,
  `SVM_R_Experiment_Index` INT NOT NULL DEFAULT -1 ,
  `SVM_R_parameters` TEXT NOT NULL ,
  `SVM_R_parameterMethod` TEXT NOT NULL ,
  `SVM_R_LostPoints` double NOT NULL DEFAULT 0,
  `SVM_R_LostPercent` double NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`SVM_R_ParameterSet_Index`) 
 )
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`SVM_Filtering` (
  `SVM_F_ParameterSet_Index` INT NOT NULL DEFAULT -1,
  `SVM_F_Analyte` varchar(50) NOT NULL,
  `SVM_F_LostPoints` double NOT NULL DEFAULT 0,
  `SVM_F_LostPointsCommon` double NOT NULL DEFAULT 0,
  `SVM_F_LostPointsAnomaly` double NOT NULL DEFAULT 0,
  `SVM_F_LostPercent` double NOT NULL DEFAULT 0 ,
  `SVM_F_LostPercentCommon` double NOT NULL DEFAULT 0 ,
  `SVM_F_LostPercentAnomaly` double NOT NULL DEFAULT 0 ,
  `SVM_F_RemainingPoints` double NOT NULL DEFAULT 0 
 )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`SVM_Length_Results`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`SVM_Length_Results` (
  `SVM_L_Result_Index` INT NOT NULL DEFAULT -1,
  `SVM_L_Length_Method` varchar(40) NOT NULL,
  `SVM_L_Analyte` varchar(50) NOT NULL,
  `SVM_L_itemName` varchar(10) NOT NULL,
  `SVM_L_Value` double NOT NULL DEFAULT 0 
 )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `Recognition_Tunneling_L_20`.`SVM_Analyte_Results`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Recognition_Tunneling_L_20`.`SVM_Analyte_Results` (
  `SVM_A_Result_Index` INT NOT NULL  AUTO_INCREMENT ,
  `SVM_A_ParameterSet_Index` INT NOT NULL DEFAULT -1,
  `SVM_A_Method` varchar(50) NOT NULL,
  `SVM_A_Analyte` varchar(50) NOT NULL,
  `SVM_A_NumberTested` double NOT NULL DEFAULT 0,
  `SVM_A_Training_Accuracy` double NOT NULL DEFAULT 0,
  `SVM_A_Testing_Accuracy` double NOT NULL DEFAULT 0,
  `SVM_A_AfterCluster` double NOT NULL DEFAULT 0 ,
  `SVM_A_AfterRun` double NOT NULL DEFAULT 0 ,
  `SVM_A_RatioAll` double NOT NULL DEFAULT 0 ,
  `SVM_A_RatioRemaining` double NOT NULL DEFAULT 0 ,
  `SVM_A_LostPoints` double NOT NULL DEFAULT 0,
  `SVM_A_LostPercent` double NOT NULL DEFAULT 0,
 PRIMARY KEY (`SVM_A_Result_Index`) 
 )
ENGINE = InnoDB;

ALTER TABLE SVM_Analyte_Results 
ADD `SVM_A_RatioCallsS`  varchar(255) NOT NULL  ;