import { DonateButton } from './DonateButton';

interface HeaderProps {
  aliasName: string | null;
}

export function Header({ aliasName }: HeaderProps) {
  return (
    <header className="bg-navy text-white flex items-center justify-between px-4 py-3 shadow-md z-50 relative">
      <h1 className="text-lg font-bold tracking-wide">Widows &amp; Orphans</h1>
      <div className="flex items-center gap-3">
        {aliasName && (
          <span className="text-xs text-chrome opacity-80" aria-label="Your anonymous alias">
            {aliasName}
          </span>
        )}
        <DonateButton />
      </div>
    </header>
  );
}
