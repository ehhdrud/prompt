#!/usr/bin/env node

import { Command } from 'commander';
import { sync } from '../src/sync.js';

const program = new Command();

program
  .name('prompt')
  .description('Claude Code / Codex 프롬프트 동기화 CLI')
  .version('0.0.1');

program
  .command('sync')
  .description('.claude/ 및 .codex/ 폴더를 원본 레포에서 동기화')
  .option('--dry-run', '실제 파일 변경 없이 미리보기만')
  .option('--force', '기존 파일 강제 덮어쓰기')
  .action(async (options) => {
    await sync(options);
  });

program.parse();
